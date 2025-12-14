# Development Guide

This repository builds the final agent images. Use it when you need to change agent installers,
adjust Dockerfiles/Bake targets, or update smoke tests.

## Prerequisites

- Docker with Buildx (`docker buildx version`).
- QEMU/binfmt for multi-arch builds (often installed with Docker Desktop).
- Bats (`bats --version`) for smoke suites.
- Python 3.11+ with `pip install -r requirements-dev.txt` to pull lint/test tooling (e.g., ruff,
  pymarkdown).

## Setup

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
```

## Repo layout

- `Dockerfile` / `docker-bake.hcl` — Buildx entrypoints for agent images.
- `tools/<tool>/install.sh` — Installer for each agent.
- `scripts/` — Build and test helpers.
- `tests/smoke/` — Bats suites that verify each tool’s image.
- `.env` — Default repositories, platforms, and version tags.

## Key configuration

`.env` controls defaults:

- `AICAGE_REPOSITORY` (default `wuodan/aicage`)
- `AICAGE_BASE_REPOSITORY` (default `wuodan/aicage-image-base`)
- `AICAGE_VERSION` (default `dev`)
- `AICAGE_PLATFORMS` (default `linux/amd64 linux/arm64`)
Base aliases are discovered from `<alias>-latest` tags in the base repository unless you override
`AICAGE_BASE_ALIASES`.

## Build

```bash
# Build and load a single agent image
scripts/build.sh --tool codex --base ubuntu --platform linux/amd64

# Build the full tool/base matrix (platforms from .env)
scripts/build-all.sh
```

## Test

```bash
# Test a specific image
scripts/test.sh --image wuodan/aicage:codex-ubuntu-latest --tool codex

# Test the full matrix (tags derived from .env and available base aliases)
scripts/test-all.sh
```

Smoke suites live in `tests/smoke/`; use `bats` directly if you need to run one file.

## Adding a tool

1. Create `tools/<tool>/install.sh` (executable) that installs the agent; fail fast on errors.
2. Add the tool to `AICAGE_TOOLS` in `.env` if it isn’t discovered automatically.
3. Add smoke coverage in `tests/smoke/<tool>.bats`.
4. Document the tool in `README.md` if it should be visible to users.

## Working with bases

Base layers come from `wuodan/aicage-image-base`. Add or modify bases in that repository, then ensure
the desired `<base>-latest` tag exists (or set `AICAGE_BASE_ALIASES`) before building here.

## CI

`aicage-image/.github/workflows/final-images.yml` builds and publishes agent images (multi-arch) on
tags. Use `act` locally if you need a dry run (requires Docker credentials to push).
