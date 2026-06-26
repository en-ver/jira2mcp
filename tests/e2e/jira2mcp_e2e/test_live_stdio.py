from __future__ import annotations

import asyncio
from collections.abc import Mapping

import pytest

from .scenarios import (
    REPO_ROOT,
    assert_contains_names,
    assert_non_error_result,
    assert_structured_content,
    call_tool_mcp,
    list_tools_mcp,
    stdio_client_mcp,
    tool_names,
)

pytestmark = [pytest.mark.mcp_live, pytest.mark.mcp_stdio]

EXPECTED_JIRA_TOOLS = [
    "jira_add_link",
    "jira_attachment",
    "jira_comment",
    "jira_comments",
    "jira_create",
    "jira_delete_link",
    "jira_edit",
    "jira_fields",
    "jira_projects",
    "jira_read",
    "jira_search",
    "jira_users",
    "jira_worklog_report",
]


def _run(awaitable):
    return asyncio.run(awaitable)


def test_stdio_smoke_lists_expected_tools(jira_e2e_stdio_env: dict[str, str]) -> None:
    async def scenario() -> None:
        async with stdio_client_mcp(
            env=jira_e2e_stdio_env,
            cwd=REPO_ROOT,
            timeout=30,
        ) as client:
            tools = await list_tools_mcp(client)
            assert_contains_names(tool_names(tools), EXPECTED_JIRA_TOOLS)

    _run(scenario())


def test_stdio_smoke_calls_safe_read_only_tool(
    jira_e2e_stdio_env: dict[str, str],
    jira_e2e_project_key: str,
) -> None:
    async def scenario() -> None:
        async with stdio_client_mcp(
            env=jira_e2e_stdio_env,
            cwd=REPO_ROOT,
            timeout=30,
        ) as client:
            result = assert_non_error_result(
                await call_tool_mcp(
                    client,
                    "jira_projects",
                    {"query": jira_e2e_project_key, "raw": True},
                )
            )
            payload = assert_structured_content(result)
            values = payload.get("values")
            if not isinstance(values, list):
                raise AssertionError(
                    "Expected jira_projects raw payload to include values"
                )
            assert any(
                isinstance(project, Mapping)
                and project.get("key") == jira_e2e_project_key
                for project in values
            )

    _run(scenario())
