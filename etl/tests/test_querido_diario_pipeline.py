from __future__ import annotations

from pathlib import Path
from unittest.mock import MagicMock

from icarus_etl.pipelines.querido_diario import QueridoDiarioPipeline

FIXTURES = Path(__file__).parent / "fixtures"


def _make_pipeline() -> QueridoDiarioPipeline:
    return QueridoDiarioPipeline(driver=MagicMock(), data_dir=str(FIXTURES))


class TestQueridoDiarioMetadata:
    def test_name(self) -> None:
        assert QueridoDiarioPipeline.name == "querido_diario"

    def test_source_id(self) -> None:
        assert QueridoDiarioPipeline.source_id == "querido_diario"


class TestQueridoDiarioTransform:
    def test_transform_counts(self) -> None:
        pipeline = _make_pipeline()
        pipeline.extract()
        pipeline.transform()

        assert len(pipeline.acts) == 2
        assert len(pipeline.company_mentions) == 1

    def test_extracts_cnpj_mentions(self) -> None:
        pipeline = _make_pipeline()
        pipeline.extract()
        pipeline.transform()

        mention = pipeline.company_mentions[0]
        assert mention["cnpj"] == "11.222.333/0001-81"
        assert mention["method"] == "text_cnpj_extract"
        assert "extract_span" in mention

    def test_sets_text_status_for_available_text(self) -> None:
        pipeline = _make_pipeline()
        pipeline.extract()
        pipeline.transform()

        statuses = {row["municipal_gazette_act_id"]: row["text_status"] for row in pipeline.acts}
        assert statuses["qd-1"] == "available"
        assert statuses["qd-2"] == "available"

    def test_does_not_extract_mentions_when_text_forbidden(self) -> None:
        pipeline = _make_pipeline()
        pipeline.extract()
        pipeline._raw_acts.append({
            "act_id": "qd-3",
            "municipality_name": "Belo Horizonte",
            "municipality_code": "3106200",
            "uf": "MG",
            "date": "2026-02-23",
            "title": "DIARIO OFICIAL",
            "text": "",
            "text_status": "forbidden",
            "txt_url": "s3://bucket/path/file.txt",
            "source_url": "https://qd/3",
            "edition": "125",
        })
        pipeline.transform()

        qd3 = next(row for row in pipeline.acts if row["municipal_gazette_act_id"] == "qd-3")
        assert qd3["text_status"] == "forbidden"
        # Only qd-1 from fixture has CNPJ mention.
        assert len(pipeline.company_mentions) == 1


class TestQueridoDiarioLoad:
    def test_load_no_raise(self) -> None:
        pipeline = _make_pipeline()
        pipeline.extract()
        pipeline.transform()
        pipeline.load()
