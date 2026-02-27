#!/usr/bin/env python3
"""Download CNJ DataJud cases when credentials are available.

Default behavior without credentials:
- writes data/datajud/dry_run_manifest.json
- exits successfully (pipeline can run in dry mode)

When configured, writes canonical files consumed by DatajudPipeline:
- data/datajud/cases.csv
- data/datajud/parties.csv
"""

from __future__ import annotations

import csv
import json
import logging
import os
from pathlib import Path
from typing import Any

import click
import httpx

logger = logging.getLogger(__name__)


def _write_dry_run_manifest(out_dir: Path, message: str) -> None:
    payload = {
        "mode": "dry-run",
        "message": message,
        "required_env": ["DATAJUD_API_URL", "DATAJUD_API_KEY"],
    }
    path = out_dir / "dry_run_manifest.json"
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    logger.info("Wrote %s", path)


def _write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        logger.warning("No rows for %s", path)
        return

    fieldnames: list[str] = []
    seen: set[str] = set()
    for row in rows:
        for key in row:
            if key not in seen:
                seen.add(key)
                fieldnames.append(key)

    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)

    logger.info("Wrote %d rows to %s", len(rows), path)


@click.command()
@click.option("--output-dir", default="./data/datajud", help="Output directory")
@click.option("--start-date", default="2024-01-01", help="Start date")
@click.option("--end-date", default="2026-12-31", help="End date")
@click.option("--max-pages", type=int, default=200, help="Maximum pages")
@click.option("--skip-existing/--no-skip-existing", default=True)
@click.option(
    "--strict-auth/--no-strict-auth",
    default=False,
    help="Fail with non-zero exit when credentials are missing.",
)
def main(
    output_dir: str,
    start_date: str,
    end_date: str,
    max_pages: int,
    skip_existing: bool,
    strict_auth: bool,
) -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    cases_path = out / "cases.csv"
    parties_path = out / "parties.csv"

    if skip_existing and cases_path.exists() and parties_path.exists():
        logger.info("Skipping (outputs exist): %s %s", cases_path, parties_path)
        return

    api_url = os.getenv("DATAJUD_API_URL", "").strip()
    api_key = os.getenv("DATAJUD_API_KEY", "").strip()

    if not api_url or not api_key:
        message = (
            "Missing credentials. Configure DATAJUD_API_URL and DATAJUD_API_KEY "
            "to enable ingestion."
        )
        _write_dry_run_manifest(out, message)
        if strict_auth:
            raise click.ClickException(message)
        return

    cases: list[dict[str, Any]] = []
    parties: list[dict[str, Any]] = []

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Accept": "application/json",
    }

    with httpx.Client(headers=headers, follow_redirects=True) as client:
        page = 1
        while page <= max_pages:
            params = {
                "start_date": start_date,
                "end_date": end_date,
                "page": page,
                "page_size": 100,
            }
            resp = client.get(api_url, params=params, timeout=60)
            resp.raise_for_status()
            payload = resp.json()

            if not isinstance(payload, dict):
                break

            data = payload.get("data")
            if not isinstance(data, list) or not data:
                break

            for record in data:
                if not isinstance(record, dict):
                    continue

                case_id = str(record.get("id") or "").strip()
                case_number = str(record.get("numero_processo") or "").strip()
                court = str(record.get("tribunal") or "").strip()
                class_name = str(record.get("classe") or "").strip()
                subject = str(record.get("assunto") or "").strip()
                filed_at = str(record.get("data_ajuizamento") or "").strip()[:10]
                status = str(record.get("situacao") or "").strip()
                source_url = str(record.get("url") or "").strip()

                cases.append({
                    "judicial_case_id": case_id,
                    "case_number": case_number,
                    "court": court,
                    "class": class_name,
                    "subject": subject,
                    "filed_at": filed_at,
                    "status": status,
                    "source_url": source_url,
                })

                entities = record.get("partes")
                if isinstance(entities, list):
                    for ent in entities:
                        if not isinstance(ent, dict):
                            continue
                        parties.append({
                            "judicial_case_id": case_id,
                            "party_name": str(ent.get("nome") or "").strip(),
                            "party_cpf": str(ent.get("cpf") or "").strip(),
                            "party_cnpj": str(ent.get("cnpj") or "").strip(),
                            "role": str(ent.get("papel") or "").strip(),
                        })

            logger.info("Fetched DataJud page=%d items=%d", page, len(data))
            if not payload.get("next_page"):
                break
            page += 1

    _write_csv(cases_path, cases)
    _write_csv(parties_path, parties)


if __name__ == "__main__":
    main()
