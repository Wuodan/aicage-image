# aicage-image

Final Docker images for [aicage](https://github.com/Wuodan/aicage). These images bundle the agent binaries on top of published
base layers from `ghcr.io/wuodan/aicage-image-base`.

## What’s included

- Agents: `cline`, `codex`, and `droid`.
- Bases: aliases such as `ubuntu`, `fedora`, and `act` (discovered from base-layer tags).
- Multi-arch support: `linux/amd64` and `linux/arm64`.

## Tag format

`${AICAGE_REPOSITORY:-ghcr.io/wuodan/aicage}:<tool>-<base>-<version>`

- Example: `ghcr.io/wuodan/aicage:codex-ubuntu-latest`
- `<base>-latest` tags map to the latest published base layer with that alias.

## Quick start

```bash
docker pull ghcr.io/wuodan/aicage:codex-ubuntu-latest

docker run -it --rm \
  -e OPENAI_API_KEY=sk-... \
  -e AICAGE_UID=$(id -u) \
  -e AICAGE_GID=$(id -g) \
  -e AICAGE_USER=$(id -un) \
  -v "$(pwd)":/workspace \
  ghcr.io/wuodan/aicage:cline-ubuntu-latest
```

Swap `codex` for `cline` or `droid`, and choose any available `<base>` alias.

## Behavior inside the container

- Starts as root, then creates a user matching `AICAGE_UID`/`AICAGE_GID`/`AICAGE_USER` (defaults
  `1000`/`1000`/`aicage`) and switches into it.
- `/workspace` is created and owned by that user; mount your project there.

## Contributing

See `DEVELOPMENT.md` for build, test, and release guidance. AI coding agents should also read
`AGENTS.md`.
