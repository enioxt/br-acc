#!/usr/bin/env python3
"""Download municipal gazette acts from Querido Diário API.

Writes canonical JSONL consumed by QueridoDiarioPipeline:
- data/querido_diario/acts.jsonl
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

import click
import httpx

logger = logging.getLogger(__name__)

QD_API_BASE = "https://api.queridodiario.ok.org.br/gazettes"


def _iter_pages(
    client: httpx.Client,
    *,
    since: str,
    until: str,
    query: str,
    max_pages: int,
) -> list[dict[str, Any]]:
    page = 1
    rows: list[dict[str, Any]] = []

    while page <= max_pages:
        params = {
            "published_since": since,
            "published_until": until,
            "q": query,
            "page": page,
            "page_size": 100,
        }
        resp = client.get(QD_API_BASE, params=params, timeout=60)
        resp.raise_for_status()
        payload = resp.json()

        if not isinstance(payload, dict):
            break

        results = payload.get("results")
        if not isinstance(results, list):
            # Current API shape uses "gazettes".
            results = payload.get("gazettes")
        if not isinstance(results, list) or not results:
            break

        for row in results:
            if isinstance(row, dict):
                rows.append(row)

        next_page = payload.get("next")
        logger.info("Querido Diário page=%d rows=%d", page, len(results))
        # Some responses do not include "next"; fallback to page-size heuristic.
        if not next_page and len(results) < 100:
            break
        page += 1

    return rows


@click.command()
@click.option("--output-dir", default="./data/querido_diario", help="Output directory")
@click.option("--since", default="2025-01-01", help="Start date (YYYY-MM-DD)")
@click.option("--until", default="2026-12-31", help="End date (YYYY-MM-DD)")
@click.option("--query", default="INSS OR previdencia OR CPMI OR CPI", help="Search query")
@click.option("--max-pages", type=int, default=50, help="Maximum paginated requests")
@click.option("--skip-existing/--no-skip-existing", default=True)
def main(
    output_dir: str,
    since: str,
    until: str,
    query: str,
    max_pages: int,
    skip_existing: bool,
) -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    acts_file = out / "acts.jsonl"

    if skip_existing and acts_file.exists() and acts_file.stat().st_size > 0:
        logger.info("Skipping (exists): %s", acts_file)
        return

    with httpx.Client(follow_redirects=True, headers={"Accept": "application/json"}) as client:
        rows = _iter_pages(client, since=since, until=until, query=query, max_pages=max_pages)

    with acts_file.open("w", encoding="utf-8") as f:
        for row in rows:
            excerpts = row.get("excerpts", [])
            excerpt_text = ""
            if isinstance(excerpts, list):
                parts: list[str] = []
                for item in excerpts:
                    if isinstance(item, str):
                        parts.append(item)
                    elif isinstance(item, dict):
                        # Querido Diário may expose excerpt chunks under text/content fields.
                        parts.append(
                            str(
                                item.get("text")
                                or item.get("content")
                                or item.get("excerpt")
                                or "",
                            ),
                        )
                excerpt_text = " ".join(p for p in parts if p).strip()

            txt_url = str(row.get("txt_url", "")).strip()
            text = str(row.get("excerpt") or excerpt_text or "").strip()
            if text:
                text_status = "available"
            elif txt_url.startswith("s3://"):
                text_status = "forbidden"
            else:
                text_status = "missing"

            mapped = {
                "act_id": str(row.get("id", "")),
                "municipality_name": str(row.get("territory_name", "")),
                "municipality_code": str(row.get("territory_id", "")),
                "uf": str(row.get("state_code", "")),
                "date": str(row.get("date", ""))[:10],
                "title": str(row.get("headline") or row.get("territory_name") or ""),
                "text": text,
                "text_status": text_status,
                "txt_url": txt_url,
                "source_url": str(row.get("url") or txt_url or ""),
                "edition": str(row.get("edition") or row.get("is_extra_edition") or ""),
            }
            f.write(json.dumps(mapped, ensure_ascii=False) + "\n")

    logger.info("Wrote %d records to %s", len(rows), acts_file)


if __name__ == "__main__":
    main()
