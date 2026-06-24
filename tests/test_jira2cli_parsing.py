from __future__ import annotations

import pytest
import typer
from jira2cli.parsing import parse_fields_json, parse_json_object


def test_parse_json_object_returns_none_for_missing_value() -> None:
    assert parse_json_object(None, option_name="--payload") is None


def test_parse_json_object_parses_dictionary_values() -> None:
    parsed = parse_json_object(
        '{"summary": "Test", "nested": {"count": 2}}', option_name="--payload"
    )

    assert parsed == {"summary": "Test", "nested": {"count": 2}}


def test_parse_json_object_rejects_invalid_json(
    capsys: pytest.CaptureFixture[str],
) -> None:
    with pytest.raises(typer.Exit) as exc_info:
        parse_json_object('{"summary": }', option_name="--payload")

    captured = capsys.readouterr()

    assert exc_info.value.exit_code == 2
    assert (
        captured.err
        == "--payload: must be valid JSON (Expecting value at line 1, column 13)\n"
    )
    assert captured.out == ""


def test_parse_json_object_rejects_non_object_json(
    capsys: pytest.CaptureFixture[str],
) -> None:
    with pytest.raises(typer.Exit) as exc_info:
        parse_json_object("[1, 2, 3]", option_name="--payload")

    captured = capsys.readouterr()

    assert exc_info.value.exit_code == 2
    assert captured.err == "--payload: must be a JSON object\n"
    assert captured.out == ""


def test_parse_fields_json_uses_expected_option_name(
    capsys: pytest.CaptureFixture[str],
) -> None:
    with pytest.raises(typer.Exit) as exc_info:
        parse_fields_json("[1, 2, 3]")

    captured = capsys.readouterr()

    assert exc_info.value.exit_code == 2
    assert captured.err == "--fields-json: must be a JSON object\n"
    assert captured.out == ""
