#!/usr/bin/env python3
"""Run ingestion-priority gates for shadow/promote workflow."""

from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass
from datetime import UTC, date, datetime

from neo4j import GraphDatabase


@dataclass(frozen=True)
class NumericGate:
    name: str
    query: str
    operator: str
    expected: int


@dataclass(frozen=True)
class DateFreshnessGate:
    name: str
    query: str
    max_age_days: int


NUMERIC_GATES: list[NumericGate] = [
    NumericGate(
        name="inquiry_count",
        query="MATCH (i:Inquiry) RETURN count(i) AS value",
        operator="gt",
        expected=3,
    ),
    NumericGate(
        name="inquiry_inss_or_previd_count",
        query=(
            "MATCH (i:Inquiry) "
            "WHERE toUpper(coalesce(i.name, '') + ' ' + coalesce(i.subject, '')) CONTAINS 'INSS' "
            "   OR toUpper(coalesce(i.name, '') + ' ' + coalesce(i.subject, '')) CONTAINS 'PREVID' "
            "RETURN count(i) AS value"
        ),
        operator="gt",
        expected=0,
    ),
    NumericGate(
        name="inquiry_requirement_count",
        query="MATCH (r:InquiryRequirement) RETURN count(r) AS value",
        operator="gt",
        expected=0,
    ),
    NumericGate(
        name="inquiry_requirement_rel_count",
        query=(
            "MATCH (:Inquiry)-[r:TEM_REQUERIMENTO]->(:InquiryRequirement) "
            "RETURN count(r) AS value"
        ),
        operator="gt",
        expected=0,
    ),
    NumericGate(
        name="absurd_future_contract_dates",
        query=(
            "MATCH (c:Contract) "
            "WHERE c.date =~ '\\d{4}-\\d{2}-\\d{2}' "
            "AND date(c.date) > date() + duration('P365D') "
            "RETURN count(c) AS value"
        ),
        operator="eq",
        expected=0,
    ),
    NumericGate(
        name="absurd_future_municipal_contract_dates",
        query=(
            "MATCH (c:MunicipalContract) "
            "WHERE c.signed_at =~ '\\d{4}-\\d{2}-\\d{2}' "
            "AND date(c.signed_at) > date() + duration('P365D') "
            "RETURN count(c) AS value"
        ),
        operator="eq",
        expected=0,
    ),
    NumericGate(
        name="absurd_future_municipal_bid_dates",
        query=(
            "MATCH (b:MunicipalBid) "
            "WHERE b.published_at =~ '\\d{4}-\\d{2}-\\d{2}' "
            "AND date(b.published_at) > date() + duration('P365D') "
            "RETURN count(b) AS value"
        ),
        operator="eq",
        expected=0,
    ),
    NumericGate(
        name="municipal_gazette_act_count",
        query="MATCH (a:MunicipalGazetteAct) RETURN count(a) AS value",
        operator="gt",
        expected=0,
    ),
    NumericGate(
        name="person_cpf_masked",
        query="MATCH (p:Person) WHERE p.cpf CONTAINS '*' RETURN count(p) AS value",
        operator="eq",
        expected=0,
    ),
    NumericGate(
        name="person_cpf_14_digits",
        query=(
            "MATCH (p:Person) "
            "WHERE replace(replace(p.cpf, '.', ''), '-', '') =~ '\\d{14}' "
            "RETURN count(p) AS value"
        ),
        operator="eq",
        expected=0,
    ),
]

DATE_GATES: list[DateFreshnessGate] = [
    DateFreshnessGate(
        name="pncp_max_date",
        query=(
            "MATCH (b:Bid) "
            "WHERE b.source = 'pncp' AND b.date =~ '\\d{4}-\\d{2}-\\d{2}' "
            "RETURN max(b.date) AS value"
        ),
        max_age_days=45,
    ),
    DateFreshnessGate(
        name="comprasnet_max_date",
        query=(
            "MATCH (c:Contract) "
            "WHERE c.source = 'comprasnet' AND c.date =~ '\\d{4}-\\d{2}-\\d{2}' "
            "RETURN max(c.date) AS value"
        ),
        max_age_days=60,
    ),
]

GAZETTE_TEXT_RATIO_QUERY = (
    "MATCH (a:MunicipalGazetteAct) "
    "RETURN count(a) AS total, "
    "sum(CASE WHEN a.text_status = 'available' THEN 1 ELSE 0 END) AS available"
)

GAZETTE_MENTION_COUNT_QUERY = (
    "MATCH (:Company)-[r:MENCIONADA_EM]->(:MunicipalGazetteAct) "
    "RETURN count(r) AS value"
)


def _passes(operator: str, value: int, expected: int) -> bool:
    if operator == "eq":
        return value == expected
    if operator == "gt":
        return value > expected
    raise ValueError(f"Unsupported operator: {operator}")


def _parse_iso_date(value: str | None) -> date | None:
    if not value:
        return None
    try:
        return datetime.strptime(value[:10], "%Y-%m-%d").replace(tzinfo=UTC).date()
    except ValueError:
        return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--uri", required=True, help="Neo4j bolt URI")
    parser.add_argument("--user", default="neo4j", help="Neo4j user")
    parser.add_argument(
        "--password-env",
        default="NEO4J_PASSWORD",
        help="Environment variable with password",
    )
    parser.add_argument(
        "--reference-date",
        default=date.today().isoformat(),
        help="Reference date for freshness checks (YYYY-MM-DD)",
    )
    args = parser.parse_args()

    password = os.getenv(args.password_env, "")
    if not password:
        print(f"[ERROR] Missing password in env var: {args.password_env}")
        return 2

    ref_date = _parse_iso_date(args.reference_date)
    if ref_date is None:
        print(f"[ERROR] Invalid --reference-date: {args.reference_date}")
        return 2

    driver = GraphDatabase.driver(args.uri, auth=(args.user, password))
    failed = 0

    try:
        with driver.session() as session:
            for gate in NUMERIC_GATES:
                value = int(session.run(gate.query).single()["value"])
                ok = _passes(gate.operator, value, gate.expected)
                expected_desc = (
                    f"== {gate.expected}" if gate.operator == "eq" else f"> {gate.expected}"
                )
                print(
                    f"[{'PASS' if ok else 'FAIL'}] {gate.name}: "
                    f"value={value} expected {expected_desc}",
                )
                if not ok:
                    failed += 1

            for gate in DATE_GATES:
                raw_value = session.run(gate.query).single()["value"]
                parsed = _parse_iso_date(raw_value)
                if parsed is None:
                    print(f"[FAIL] {gate.name}: no valid max date found")
                    failed += 1
                    continue

                age_days = (ref_date - parsed).days
                ok = age_days <= gate.max_age_days
                print(
                    f"[{'PASS' if ok else 'FAIL'}] {gate.name}: "
                    f"max_date={parsed.isoformat()} "
                    f"age_days={age_days} max_allowed={gate.max_age_days}",
                )
                if not ok:
                    failed += 1

            ratio_row = session.run(GAZETTE_TEXT_RATIO_QUERY).single()
            total_acts = int(ratio_row["total"] or 0)
            available_acts = int(ratio_row["available"] or 0)
            ratio = (available_acts / total_acts) if total_acts > 0 else 0.0
            print(
                "[INFO] gazette_text_available_ratio: "
                f"available={available_acts} total={total_acts} ratio={ratio:.3f}",
            )

            if ratio >= 0.2:
                mention_count = int(session.run(GAZETTE_MENTION_COUNT_QUERY).single()["value"])
                ok = mention_count > 0
                print(
                    f"[{'PASS' if ok else 'FAIL'}] municipal_gazette_mentions: "
                    f"value={mention_count} expected > 0 (ratio >= 0.2)",
                )
                if not ok:
                    failed += 1
            else:
                print(
                    "[WARN] municipal_gazette_mentions gate relaxed: "
                    f"gazette_text_available_ratio={ratio:.3f} < 0.2",
                )
    finally:
        driver.close()

    if failed:
        print(f"[SUMMARY] {failed} gate(s) failed.")
        return 1

    print("[SUMMARY] All ingestion-priority gates passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
