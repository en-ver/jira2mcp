# Attachment Download

Use this when the issue context already identifies a Jira attachment ID and you need to save the file locally.

## Workflow

1. Read the issue first so the attachment target is explicit:
   - `uv run --package jira2cli jira2cli read <KEY> --json`
2. Confirm the exact attachment ID and expected file name before downloading.
3. Download the attachment:
   - `uv run --package jira2cli jira2cli attachment <ATTACHMENT_ID>`
4. Use `--output-path <path>` when you need a specific directory or full file path:
   - `uv run --package jira2cli jira2cli attachment <ATTACHMENT_ID> --output-path <path>`
5. Verify that the saved path matches the intended destination before using the file in later steps.

Do not guess attachment IDs or overwrite an unexpected destination path without confirming it.
