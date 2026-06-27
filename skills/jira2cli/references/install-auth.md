# Install and Authenticate

`jira2cli` is currently documented in this repo as local/dev-only.

## Supported Local Verification

From the repository root:

```sh
uv sync --all-packages --group dev
uv run --package jira2cli jira2cli --help
```

Use the same `uv run --package jira2cli jira2cli ...` prefix for the other commands in this skill.

Do not claim or rely on `uvx jira2cli`, `pip install jira2cli`, or wheel/PyPI install paths unless the repo docs change first.

## Authentication

`jira2cli` reads these environment variables:

- `JIRA_URL=https://<site>.atlassian.net`
- `JIRA_USER=<email>`
- `JIRA_API_TOKEN=<api-token>`

Rules:

- Keep `JIRA_API_TOKEN` in a local environment file, secret manager, or interactive secret prompt.
- Never print `JIRA_API_TOKEN`, paste it into chat, or commit it to the repo.
- Keep `JIRA_URL` as the full Jira Cloud base URL, including `https://`.

## Read-Only Verification

After the environment is configured, verify access with a non-mutating command such as:

- `uv run --package jira2cli jira2cli projects --json`
- `uv run --package jira2cli jira2cli projects --query <text> --json`

If verification fails, fix the environment values instead of guessing or exposing the token.
