"""CLI rendering and error helpers for jira2cli."""

from __future__ import annotations

import json
from typing import Any, NoReturn

import typer
from jira2ai_core.errors import Jira2AIError, Jira2AIValidationError
from jira2ai_core.results import OperationResult


def render_operation_result(
    result: OperationResult,
    *,
    json_output: bool = False,
    raw_output: bool = False,
) -> str:
    """Render an operation result for CLI stdout."""
    if json_output or raw_output:
        return json.dumps(
            _json_payload(result),
            indent=2,
            sort_keys=True,
            default=str,
        )
    return result.text


def _json_payload(result: OperationResult) -> Any:
    """Select the most structured payload available for JSON output."""
    if result.data is not None:
        return result.data

    if result.raw_content is None:
        return result.text

    try:
        return json.loads(result.raw_content)
    except json.JSONDecodeError:
        return result.raw_content


def format_cli_error(error: Jira2AIError) -> str:
    """Format a core error for CLI stderr."""
    if not error.details:
        return error.message

    return (
        f"{error.message}\n"
        f"Details:\n{json.dumps(error.details, indent=2, sort_keys=True, default=str)}"
    )


def error_exit_code(error: Jira2AIError) -> int:
    """Return the CLI exit code for a core error."""
    if isinstance(error, Jira2AIValidationError):
        return 2
    return 1


def raise_cli_usage_error(
    message: str,
    *,
    param_hint: str | None = None,
) -> NoReturn:
    """Write a CLI usage error to stderr and exit with code 2."""
    if param_hint:
        typer.echo(f"{param_hint}: {message}", err=True)
    else:
        typer.echo(message, err=True)
    raise typer.Exit(code=2)


def validate_output_options(*, json_output: bool, raw_output: bool) -> None:
    """Reject conflicting structured output flags."""
    if json_output and raw_output:
        raise_cli_usage_error(
            "Use only one of --json or --raw.",
            param_hint="--json / --raw",
        )


def raise_cli_error(error: Jira2AIError) -> NoReturn:
    """Write a CLI-friendly core error message to stderr and exit."""
    typer.echo(format_cli_error(error), err=True)
    raise typer.Exit(code=error_exit_code(error))


def raise_cli_exception(error: Exception) -> NoReturn:
    """Write a CLI-friendly error message to stderr and exit."""
    if isinstance(error, Jira2AIError):
        raise_cli_error(error)

    typer.echo(str(error), err=True)
    raise typer.Exit(code=1)


__all__ = [
    "error_exit_code",
    "format_cli_error",
    "raise_cli_error",
    "raise_cli_exception",
    "raise_cli_usage_error",
    "render_operation_result",
    "validate_output_options",
]
