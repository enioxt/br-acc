from __future__ import annotations

import importlib.util
import json
from pathlib import Path
from typing import TYPE_CHECKING

from click.testing import CliRunner

if TYPE_CHECKING:
    from types import ModuleType


def _load_script_module(filename: str, module_name: str) -> ModuleType:
    scripts_dir = Path(__file__).resolve().parents[1] / "scripts"
    script_path = scripts_dir / filename
    spec = importlib.util.spec_from_file_location(module_name, script_path)
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_download_mides_fails_when_all_tables_fail(monkeypatch, tmp_path: Path) -> None:
    module = _load_script_module("download_mides.py", "download_mides_test_fail")

    def _always_fail(*args, **kwargs):  # type: ignore[no-untyped-def]
        raise RuntimeError("boom")

    monkeypatch.setattr(module, "_run_query_to_csv", _always_fail)
    runner = CliRunner()
    result = runner.invoke(
        module.main,
        ["--output-dir", str(tmp_path), "--no-skip-existing"],
    )

    assert result.exit_code != 0
    manifest_path = tmp_path / "download_manifest.json"
    assert manifest_path.exists()
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert payload["summary"]["failed"] == 3
    assert payload["summary"]["ok"] == 0


def test_download_mides_partial_success_writes_manifest(
    monkeypatch,
    tmp_path: Path,
) -> None:
    module = _load_script_module("download_mides.py", "download_mides_test_partial")

    def _partial(*args, **kwargs):  # type: ignore[no-untyped-def]
        output_path = kwargs.get("output_path") or args[2]
        if output_path.name == "licitacao.csv":
            return 12
        raise RuntimeError("table failure")

    monkeypatch.setattr(module, "_run_query_to_csv", _partial)
    runner = CliRunner()
    result = runner.invoke(
        module.main,
        ["--output-dir", str(tmp_path), "--no-skip-existing"],
    )

    assert result.exit_code == 0
    manifest_path = tmp_path / "download_manifest.json"
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert payload["summary"]["ok"] == 1
    assert payload["summary"]["failed"] == 2


def test_download_datajud_strict_auth_fails_without_credentials(
    monkeypatch,
    tmp_path: Path,
) -> None:
    module = _load_script_module("download_datajud.py", "download_datajud_test_strict")
    monkeypatch.delenv("DATAJUD_API_URL", raising=False)
    monkeypatch.delenv("DATAJUD_API_KEY", raising=False)

    runner = CliRunner()
    result = runner.invoke(
        module.main,
        ["--output-dir", str(tmp_path), "--no-skip-existing", "--strict-auth"],
    )

    assert result.exit_code != 0
    assert (tmp_path / "dry_run_manifest.json").exists()


def test_download_datajud_non_strict_keeps_dry_run_success(
    monkeypatch,
    tmp_path: Path,
) -> None:
    module = _load_script_module("download_datajud.py", "download_datajud_test_non_strict")
    monkeypatch.delenv("DATAJUD_API_URL", raising=False)
    monkeypatch.delenv("DATAJUD_API_KEY", raising=False)

    runner = CliRunner()
    result = runner.invoke(
        module.main,
        ["--output-dir", str(tmp_path), "--no-skip-existing"],
    )

    assert result.exit_code == 0
    assert (tmp_path / "dry_run_manifest.json").exists()
