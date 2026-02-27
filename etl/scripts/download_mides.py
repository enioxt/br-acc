#!/usr/bin/env python3
"""Download MiDES municipal procurement datasets from BigQuery.

Outputs canonical files consumed by MidesPipeline:
- data/mides/licitacao.csv
- data/mides/contrato.csv
- data/mides/item.csv
"""

from __future__ import annotations

import json
import logging
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import click

logger = logging.getLogger(__name__)


def _run_query_to_csv(
    billing_project: str,
    query: str,
    output_path: Path,
    *,
    skip_existing: bool,
) -> int:
    if skip_existing and output_path.exists() and output_path.stat().st_size > 0:
        logger.info("Skipping (exists): %s", output_path)
        return -1

    try:
        import google.auth
        from google.cloud import bigquery
    except ImportError as exc:
        raise RuntimeError("Install optional deps: pip install '.[bigquery]'") from exc

    credentials, _ = google.auth.default()
    client = bigquery.Client(project=billing_project, credentials=credentials)

    logger.info("Querying BigQuery into %s", output_path.name)
    df = client.query(query).result().to_dataframe(create_bqstorage_client=True)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)
    logger.info("Wrote %d rows to %s", len(df), output_path)
    return int(len(df))


def _write_manifest(out_dir: Path, tables: list[dict[str, Any]]) -> Path:
    path = out_dir / "download_manifest.json"
    payload = {
        "generated_at_utc": datetime.now(UTC).isoformat(),
        "source": "mides",
        "tables": tables,
        "summary": {
            "ok": sum(1 for t in tables if t["status"] == "ok"),
            "skipped_existing": sum(
                1 for t in tables if t["status"] == "skipped_existing"
            ),
            "failed": sum(1 for t in tables if t["status"] == "failed"),
        },
    }
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    logger.info("Wrote manifest to %s", path)
    return path


@click.command()
@click.option("--billing-project", default="icarus-corruptos", help="GCP billing project")
@click.option("--dataset", default="basedosdados.br_mides", help="BigQuery dataset id")
@click.option("--output-dir", default="./data/mides", help="Output directory")
@click.option("--start-year", type=int, default=2021, help="Filter start year")
@click.option("--end-year", type=int, default=2100, help="Filter end year")
@click.option("--skip-existing/--no-skip-existing", default=True)
def main(
    billing_project: str,
    dataset: str,
    output_dir: str,
    start_year: int,
    end_year: int,
    skip_existing: bool,
) -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    year_filter = (
        f"WHERE SAFE_CAST(ano AS INT64) BETWEEN {start_year} AND {end_year}"
    )

    queries = {
        "licitacao.csv": (
            f"SELECT * FROM `{dataset}.licitacao` {year_filter}"
        ),
        "contrato.csv": (
            f"SELECT * FROM `{dataset}.contrato` {year_filter}"
        ),
        "item.csv": (
            f"SELECT * FROM `{dataset}.item` {year_filter}"
        ),
    }

    tables: list[dict[str, Any]] = []

    for filename, query in queries.items():
        table_name = filename.replace(".csv", "")
        entry = {
            "table": table_name,
            "file": filename,
            "status": "failed",
            "rows": 0,
            "error": "",
        }
        try:
            rows = _run_query_to_csv(
                billing_project,
                query,
                out / filename,
                skip_existing=skip_existing,
            )
            if rows == -1:
                entry["status"] = "skipped_existing"
            else:
                entry["status"] = "ok"
                entry["rows"] = rows
        except Exception as exc:  # noqa: BLE001
            logger.warning("Failed %s: %s", filename, exc)
            entry["error"] = str(exc)
        tables.append(entry)

    _write_manifest(out, tables)
    successful = sum(1 for t in tables if t["status"] in {"ok", "skipped_existing"})
    if successful == 0:
        raise click.ClickException(
            "No canonical MiDES tables downloaded successfully (0/3).",
        )


if __name__ == "__main__":
    main()
