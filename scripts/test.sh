#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SMOKE_DIR="${ROOT_DIR}/tests/smoke"
IMAGE_REF=""
TOOL=""
BATS_TOOL_FILE="${SMOKE_DIR}/tool.bats"

usage() {
  cat <<'USAGE'
Usage: scripts/test.sh --image <image-ref> --tool <tool> [bats-args...]

Options:
  --image <ref>   Image reference to test (required)
  --tool <tool>   Tool name for smoke tests (required)
  -h, --help      Show this help and exit

Examples:
  scripts/test.sh --image example/aicage:codex-ubuntu-24.04-latest --tool codex
USAGE
  exit 1
}

# shellcheck source=../scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

log() {
  printf '[test] %s\n' "$*" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      [[ $# -ge 2 ]] || usage
      IMAGE_REF="$2"
      shift 2
      ;;
    --tool)
      [[ $# -ge 2 ]] || usage
      TOOL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "${IMAGE_REF}" ]] || { log "--image is required"; usage; }
[[ -n "${TOOL}" ]] || { log "--tool is required"; usage; }

if [[ ! -e "${BATS_TOOL_FILE}" ]]; then
  log "Smoke tests not found at ${BATS_TOOL_FILE}."
  exit 1
fi

log "Running smoke tests via bats"
AICAGE_IMAGE="${IMAGE_REF}" TOOL="${TOOL}" bats "${BATS_TOOL_FILE}" "$@"
