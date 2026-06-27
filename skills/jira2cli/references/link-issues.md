# Link Issues

Use this when the user wants to add or remove a relationship between two Jira issues.

## Workflow

1. Read both issues before changing links:
   - `uv run --package jira2cli jira2cli read <OUTWARD_KEY> --json`
   - `uv run --package jira2cli jira2cli read <INWARD_KEY> --json`
2. Discover valid link types:
   - `uv run --package jira2cli jira2cli link-types --json`
3. Confirm the exact link type and direction. Use the outward and inward labels from the link type output to decide which issue key belongs in each position.
4. Summarize the two issue keys, the chosen type, and the chosen direction. Ask the user to confirm.

## Add a Link

After confirmation only, run:

- `uv run --package jira2cli jira2cli add-link <LINK_TYPE> <OUTWARD_KEY> <INWARD_KEY> --json`
- If you need the untouched API payload instead of structured confirmation, rerun with `--raw` instead of `--json`.

## Delete an Existing Link

1. Use the issue read output to capture the exact existing link ID for the relationship you want to remove.
2. Confirm the link ID and the relationship it represents.
3. After confirmation only, run:
   - `uv run --package jira2cli jira2cli delete-link <LINK_ID> --json`
4. If you need the untouched API payload instead of structured confirmation, rerun with `--raw` instead of `--json`.

Never guess link direction or delete a link by description alone.
