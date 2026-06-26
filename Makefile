.PHONY: lint format type-check test test-mcp-e2e test-mcp-e2e-stdio test-mcp-e2e-write check check-ci clean help build build-jira2mcp build-jira2cli build-all bump-version version-current release-prep release push-release-tag ensure-main-clean

PACKAGE ?= jira2mcp
PART ?= patch
VERSION_INPUT := $(or $(VERSION),$(v))
MCP_PACKAGE_DIR := packages/jira2mcp
CLI_PACKAGE_DIR := packages/jira2cli
CHECK_PATHS := $(MCP_PACKAGE_DIR)/src $(CLI_PACKAGE_DIR)/src scripts tests
TYPECHECK_PATHS := $(MCP_PACKAGE_DIR)/src/ $(CLI_PACKAGE_DIR)/src/ scripts/
PYTEST_NON_LIVE_ARGS := -m "not mcp_live"
MCP_E2E_PATH := tests/e2e/jira2mcp_e2e
MCP_E2E_READONLY_ARGS := $(MCP_E2E_PATH) -m "mcp_live and not mcp_write"
MCP_E2E_STDIO_ARGS := $(MCP_E2E_PATH) -m "mcp_live and mcp_stdio and not mcp_write"
MCP_E2E_WRITE_ARGS := $(MCP_E2E_PATH) -m "mcp_live and mcp_write"

help:
	@echo "Available targets:"
	@echo "  lint             - Run ruff linting with auto-fix"
	@echo "  format           - Run ruff formatting"
	@echo "  type-check       - Run ty type checking"
	@echo "  test             - Run pytest excluding live MCP E2E tests"
	@echo "  test-mcp-e2e     - Run live read-only MCP E2E tests"
	@echo "  test-mcp-e2e-stdio - Run live stdio MCP E2E smoke tests"
	@echo "  test-mcp-e2e-write - Run live write MCP E2E tests (requires JIRA_E2E_ALLOW_WRITE=1)"
	@echo "  check            - Run mutating local checks (lint, format, type-check)"
	@echo "  check-ci         - Run non-mutating CI-style checks, including tests"
	@echo "  build            - Build the selected package (default: jira2mcp; override with PACKAGE=...)"
	@echo "  build-jira2mcp   - Build jira2mcp sdist and wheel"
	@echo "  build-jira2cli   - Build jira2cli sdist and wheel"
	@echo "  build-all        - Build all workspace packages"
	@echo "  bump-version     - Bump selected package version (default patch) or set VERSION=0.2.0 / v=0.2.0"
	@echo "  version-current  - Print the current selected package version"
	@echo "  release-prep     - Validate selected package release readiness, bump version, and run non-mutating checks"
	@echo "  release          - Create a local annotated release tag for the selected package from a clean main branch"
	@echo "  push-release-tag - Push the current selected package release tag only"
	@echo "  clean            - Clean Python cache files"
	@echo "  help             - Show this help message"

# Run ruff linting with auto-fix
lint:
	uv run ruff check --fix $(CHECK_PATHS)

# Run ruff formatting
format:
	uv run ruff format $(CHECK_PATHS)

# Run ty type checking
type-check:
	uv run ty check $(TYPECHECK_PATHS)

# Run pytest
test:
	uv run --locked python -m pytest $(PYTEST_NON_LIVE_ARGS)

# Run live read-only MCP E2E tests
test-mcp-e2e:
	uv run --locked python -m pytest $(MCP_E2E_READONLY_ARGS)

# Run live stdio MCP E2E smoke tests
test-mcp-e2e-stdio:
	uv run --locked python -m pytest $(MCP_E2E_STDIO_ARGS)

# Run live write MCP E2E tests
test-mcp-e2e-write:
	@test "$(JIRA_E2E_ALLOW_WRITE)" = "1" || (echo "Set JIRA_E2E_ALLOW_WRITE=1 to run mcp_write tests." && exit 1)
	uv run --locked python -m pytest $(MCP_E2E_WRITE_ARGS)

# Run all checks
check: lint format type-check

# Run non-mutating CI-style checks
check-ci:
	uv run --locked ruff check $(CHECK_PATHS)
	uv run --locked ruff format --check $(CHECK_PATHS)
	uv run --locked ty check $(TYPECHECK_PATHS)
	uv run --locked python -m pytest $(PYTEST_NON_LIVE_ARGS)

# Build sdist and wheel
build: clean
	uv build --package $(PACKAGE)

build-jira2mcp:
	uv build --package jira2mcp

build-jira2cli:
	uv build --package jira2cli

build-all: clean build-jira2mcp build-jira2cli

# Print the current project version
version-current:
	@uv run --frozen python scripts/bump_version.py --package "$(PACKAGE)" --current

# Bump the project version
bump-version:
	@args="--part $(PART)"; \
	if [ -n "$(VERSION_INPUT)" ]; then args="--version $(VERSION_INPUT)"; fi; \
	new_version="$$(uv run --frozen python scripts/bump_version.py --package "$(PACKAGE)" $$args)" || exit $$?; \
	echo "Version set to $$new_version"

# Prepare a release before opening a PR to main
release-prep:
	@uv run --frozen python scripts/bump_version.py --package "$(PACKAGE)" --validate-release
	$(MAKE) bump-version PACKAGE="$(PACKAGE)" VERSION="$(VERSION_INPUT)" PART="$(PART)"
	uv lock
	$(MAKE) check-ci
	$(MAKE) build PACKAGE="$(PACKAGE)"
	@echo "Release prep complete for $(PACKAGE)-v$$(uv run --locked python scripts/bump_version.py --package "$(PACKAGE)" --current)"
	@echo "Review the diff and open a PR from dev to main."

# Require a clean main branch before tagging a release
ensure-main-clean:
	@test "$$(git branch --show-current)" = "main" || (echo "Release tagging must be run from the main branch." && exit 1)
	@git diff --quiet || (echo "Working tree must be clean before tagging a release." && exit 1)
	@git diff --cached --quiet || (echo "Index must be clean before tagging a release." && exit 1)

# Create a local release tag without pushing main or force-updating tags
release: ensure-main-clean
	@version="$$(uv run --frozen python scripts/bump_version.py --package "$(PACKAGE)" --current)"; \
	tag="$(PACKAGE)-v$$version"; \
	if git rev-parse -q --verify "refs/tags/$$tag" >/dev/null; then \
		echo "Local tag $$tag already exists."; \
		exit 1; \
	fi; \
	if git ls-remote --exit-code --tags origin "refs/tags/$$tag" >/dev/null 2>&1; then \
		echo "Remote tag $$tag already exists."; \
		exit 1; \
	fi; \
	git tag -a "$$tag" -m "Release $$tag"; \
	echo "Created local tag $$tag"

# Push the release tag only to trigger publishing
push-release-tag:
	@version="$$(uv run --frozen python scripts/bump_version.py --package "$(PACKAGE)" --current)"; \
	tag="$(PACKAGE)-v$$version"; \
	git rev-parse -q --verify "refs/tags/$$tag" >/dev/null || { echo "Local tag $$tag does not exist."; exit 1; }; \
	git push origin "refs/tags/$$tag"

# Clean Python cache files
clean:
	find . -path ./.git -prune -o -path ./.venv -prune -o -type f -name "*.py[co]" -exec rm -f {} +
	find . -path ./.git -prune -o -path ./.venv -prune -o -type d -name "__pycache__" -exec rm -rf {} +
	find . -path ./.git -prune -o -path ./.venv -prune -o -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf .mypy_cache/ .ty/ .ruff_cache/ .pytest_cache/ dist/ build/ $(MCP_PACKAGE_DIR)/dist/ $(MCP_PACKAGE_DIR)/build/ $(CLI_PACKAGE_DIR)/dist/ $(CLI_PACKAGE_DIR)/build/
