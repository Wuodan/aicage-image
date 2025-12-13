# aicage-image

Final Docker images for AI coding agents (`cline`, `codex`, `droid`). Base layers live in the
`aicage-image-base` repo; this repo consumes `${AICAGE_BASE_REPOSITORY}:<alias>-latest` tags to build
the agent layers.

## Layout

- `Dockerfile` / `docker-bake.hcl` — Buildx entrypoints for agent images.
- `scripts/` — Build/test helpers and installers.
- `tests/smoke/` — Bats smoke suite shared by all tools.
- `.env` — Defaults for repositories, platforms, and tool list.

## Build

Make sure the base images you want to consume exist at `${AICAGE_BASE_REPOSITORY}`.

```bash
# Build and load a single agent image
scripts/build.sh --tool codex --base ubuntu --platform linux/amd64

# Build the full tool/base matrix
scripts/build-all.sh --platform linux/amd64
```

## Test

```bash
# Test a single image
scripts/test.sh --image wuodan/aicage:codex-ubuntu-latest

# Test the full matrix (tags derived from .env)
scripts/test-all.sh
```

## GitHub Actions

`.github/workflows/final-images.yml` builds/tests on tags and pushes to
`${AICAGE_REPOSITORY}`. Run locally with:

```bash
act -W .github/workflows/final-images.yml -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

## Configuration

Key `.env` variables (can be overridden via environment):
- `AICAGE_REPOSITORY` — Target repo for agent images (default `wuodan/aicage`).
- `AICAGE_BASE_REPOSITORY` — Source repo for base layers (default `wuodan/aicage-image-base`).
- `AICAGE_VERSION` — Tag suffix, appended as `<tool>-<base>-<version>` (default `dev`).
- `AICAGE_PLATFORMS` — Space-separated platform list.
- `AICAGE_TOOLS` — Tool list to build/test.
