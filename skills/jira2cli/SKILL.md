---
name: jira2cli
description: Jira Cloud workflows through local `jira2cli` in this repo. Use when verifying `jira2cli`, discovering Jira metadata, reading issues/comments/worklogs, downloading attachments, or safely mutating Jira issues.
---

# jira2cli

Use `jira2cli` for Jira Cloud workflows from a local checkout of this repository.

## References

- [references/install-auth.md](references/install-auth.md) — Load when you need the supported local/dev command prefix, CLI verification, or Jira auth setup.
- [references/project-discovery.md](references/project-discovery.md) — Load when you need to resolve the right Jira project key or discover issue types with `fields --project-key`.
- [references/field-metadata.md](references/field-metadata.md) — Load before create/edit work when you need required fields, editable fields, or allowed values.
- [references/user-identity-lookup.md](references/user-identity-lookup.md) — Load when a Jira user field needs an `accountId` or exact display name.
- [references/jql-syntax.md](references/jql-syntax.md) — Load when composing or debugging JQL.
- [references/search-and-read-issues.md](references/search-and-read-issues.md) — Load when you need to search issues, read details, request extra fields, or page through comments.
- [references/worklog-report.md](references/worklog-report.md) — Load when you need `worklog-report` date-range reporting or worklog filtering details.
- [references/attachment-download.md](references/attachment-download.md) — Load when you need to download an attachment and choose `--output-path`.
- [references/create-issue.md](references/create-issue.md) — Load before creating a Jira issue.
- [references/edit-issue.md](references/edit-issue.md) — Load before editing a Jira issue.
- [references/comment-on-issue.md](references/comment-on-issue.md) — Load before posting a Jira comment.
- [references/link-issues.md](references/link-issues.md) — Load before adding or deleting Jira issue links.

## Mandatory Skill/CLI Alignment Rule

Any future change to `skills/jira2cli`, `packages/jira2cli/src/jira2cli/cli.py`, `packages/jira2cli/src/jira2cli/commands/*.py`, or `packages/jira2cli/README.md` must verify that this skill still matches the current CLI.

Required verification:

- compare this skill against `packages/jira2cli/src/jira2cli/cli.py`
- compare this skill against `packages/jira2cli/src/jira2cli/commands/*.py`
- compare this skill against `packages/jira2cli/README.md`
- verify commands and options against current help output from `uv run --package jira2cli jira2cli --help` and each command `--help`

If the skill text and the CLI/help output disagree, fix or qualify the docs before proceeding.

## Common Safety Rules

- This repo currently supports local/dev `jira2cli` usage from the workspace root: `uv run --package jira2cli jira2cli ...`.
- Do not claim `uvx jira2cli`, PyPI install, or wheel auto-discovery support unless the repo docs and CLI release flow are updated first.
- Never print `JIRA_API_TOKEN` or other secrets.
- Do not guess project keys, issue types, user identities, required Jira fields, attachment IDs, or link direction.
- Before create, edit, comment, link, delete-link, or attachment actions, gather the relevant issue state or metadata first.
- Before mutating Jira, summarize the intended action, the exact field choices or link direction, and ask the user to confirm.
- Prefer `--json` for structured reads and structured mutation confirmations.
- Use `--raw` only when you need the untouched API payload, and do not pass `--raw` and `--json` together.

## Common Commands

- `uv run --package jira2cli jira2cli --help`
- `uv run --package jira2cli jira2cli projects --query <text> --json`
- `uv run --package jira2cli jira2cli fields --project-key <PROJECT> --json`
- `uv run --package jira2cli jira2cli fields --project-key <PROJECT> --issue-type <TYPE> --json`
- `uv run --package jira2cli jira2cli fields --issue-key <KEY> --json`
- `uv run --package jira2cli jira2cli users <query> --max-results <N> --json`
- `uv run --package jira2cli jira2cli jql-syntax`
- `uv run --package jira2cli jira2cli search '<JQL>' --field key --field summary --field status --max-results <N> --json`
- `uv run --package jira2cli jira2cli read <KEY> --extra-field <FIELD_ID> --json`
- `uv run --package jira2cli jira2cli comments <KEY> --start-at <N> --max-results <N> --order-by -created --json`
- `uv run --package jira2cli jira2cli worklog-report --start-date <YYYY-MM-DD> --end-date <YYYY-MM-DD> --jql '<JQL>' --account-id <ACCOUNT_ID> --max-issues <N> --include-details --json`
- `uv run --package jira2cli jira2cli attachment <ATTACHMENT_ID> --output-path <path>`
- `uv run --package jira2cli jira2cli create <PROJECT> <TYPE> <SUMMARY> --description <text> --fields-json '<json>' --json`
- `uv run --package jira2cli jira2cli edit <KEY> --summary <text> --description <text> --fields-json '<json>' --json`
- `uv run --package jira2cli jira2cli comment <KEY> <BODY> --json`
- `uv run --package jira2cli jira2cli link-types --json`
- `uv run --package jira2cli jira2cli add-link <LINK_TYPE> <OUTWARD_KEY> <INWARD_KEY> --json`
- `uv run --package jira2cli jira2cli delete-link <LINK_ID> --json`
