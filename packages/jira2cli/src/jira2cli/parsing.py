"""Parsing helpers for jira2cli options and arguments."""

from __future__ import annotations

import json
from typing import Any

from jira2cli.output import raise_cli_usage_error


def parse_json_object(
    value: str | None,
    *,
    option_name: str,
) -> dict[str, Any] | None:
    """Parse an optional JSON object string into a dictionary."""
    if value is None:
        return None

    try:
        parsed = json.loads(value)
    except json.JSONDecodeError as exc:
        raise_cli_usage_error(
            f"must be valid JSON ({exc.msg} at line {exc.lineno}, column {exc.colno})",
            param_hint=option_name,
        )

    if not isinstance(parsed, dict):
        raise_cli_usage_error("must be a JSON object", param_hint=option_name)

    return parsed


def parse_fields_json(value: str | None) -> dict[str, Any] | None:
    """Parse the ``--fields-json`` option into a dictionary."""
    return parse_json_object(value, option_name="--fields-json")


__all__ = ["parse_fields_json", "parse_json_object"]
