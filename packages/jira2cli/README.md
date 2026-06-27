# jira2cli

CLI adapter for Jira Cloud, powered by `jira2py` helpers.

`jira2cli` is currently intended for local and development use from this workspace. Do not assume a published `uvx` or PyPI install path yet.

## Environment

`jira2cli` uses the same Jira credentials as `jira2mcp`:

| Variable | Description |
|---|---|
| `JIRA_URL` | Your Jira instance URL |
| `JIRA_USER` | Your Jira account email |
| `JIRA_API_TOKEN` | Your Jira API token |

Example:

```bash
export JIRA_URL="https://yourcompany.atlassian.net"
export JIRA_USER="you@company.com"
export JIRA_API_TOKEN="your-api-token"
```

## Local usage

From the workspace root:

```bash
uv sync --all-packages --group dev
uv run --package jira2cli jira2cli --help
uv run --package jira2cli jira2cli read PROJ-123
uv run --package jira2cli jira2cli search 'project = PROJ ORDER BY updated DESC'
uv run --package jira2cli jira2cli fields --project-key PROJ
uv run --package jira2cli jira2cli worklog-report --start-date 2026-06-12 --end-date 2026-06-13 --jql 'issue = PROJ-123'
```

## Pi skill reference

The Pi skill reference lives at repo-root `skills/jira2cli/`.

It is CLI-only, not a `jira2mcp`/MCP skill, and documents metadata-first Jira workflows plus safety rules for agents using `jira2cli`.

Consumers can use it as a reference/template for building their own Pi or agent skills. Load it from a local source checkout via an explicit skill path, for example:

```json
{
  "skills": ["/Users/enver/github/personal/jira2ai/skills/jira2cli"]
}
```

Do not assume Pi auto-discovers this skill from a Python wheel, PyPI install, or `uvx` install.

## Worklog reports

Use `jira2cli worklog-report` to build a report for issues selected by JQL.

- Required options: `--start-date`, `--end-date`, and `--jql`.
- Optional options: `--account-id`, `--max-issues`, `--include-details`, `--json`, and `--raw`.
- Issue selection is JQL-only. For a single issue, use `--jql 'issue = PROJ-123'`.
- Dates are interpreted in UTC, and `--end-date` is inclusive.
- `--account-id` filters returned worklogs client-side by author `accountId`.
- `--max-issues` defaults to `100`, must be at least `1`, and limits how many JQL-matched issues are scanned; the report notes truncation when more issues match.
- Output rows use `displayName` as the friendly user name.
- Results depend on the configured Jira account's issue/worklog visibility and permissions.

## Workspace layout

- `packages/jira2mcp` — MCP adapter published as `jira2mcp`.
- `packages/jira2cli` — CLI adapter package.

For MCP installs and Claude setup, use `uvx jira2mcp` and `claude mcp add jira -- uvx jira2mcp` as documented in the repository root README.

## Maintainers

Do not assume `uvx jira2cli` or `pip install jira2cli` is available yet. Keep using local workspace commands until the release gates in the maintainer docs are completed.

Release sequencing, package tags, and Trusted Publishing boundaries:

- <https://github.com/en-ver/jira2ai/blob/main/docs/releasing.md>
- <https://github.com/en-ver/jira2ai/blob/main/CONTRIBUTING.md>
