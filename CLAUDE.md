# Project Rules

## After Every Significant Set of Changes

Run the formatter, linter, and type checker before considering work complete:

```bash
ruff format src/ scripts/
ruff check --fix src/ scripts/
ty check src/ scripts/
```

Always use the `--fix` flag (or equivalent) when the tool supports it, so that auto-fixable violations are resolved automatically. Only manually fix what the tools cannot auto-fix.

Fix any remaining errors before proceeding. Warnings from `ty` may be reviewed but are not blocking.
