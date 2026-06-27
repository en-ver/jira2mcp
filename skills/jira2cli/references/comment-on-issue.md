# Comment on an Issue

Use this when the user wants to add a comment to an existing Jira issue.

## Workflow

1. Read the current issue:
   - `uv run --package jira2cli jira2cli read <KEY> --json`
2. Review the existing discussion first:
   - `uv run --package jira2cli jira2cli comments <KEY> --json`
3. If the thread is long, page or reorder comment reads before drafting the reply:
   - `uv run --package jira2cli jira2cli comments <KEY> --start-at <N> --max-results <N> --order-by -created --json`
4. Draft the exact comment body and summarize where it will be posted.
5. Ask the user to confirm the target issue and final body.
6. After confirmation only, run:
   - `uv run --package jira2cli jira2cli comment <KEY> <BODY> --json`
7. If you need the untouched API payload instead of structured confirmation, rerun with `--raw` instead of `--json`.

Do not post a comment before checking the current issue and recent comments.
