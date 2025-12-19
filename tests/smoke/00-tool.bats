#!/usr/bin/env bats

setup() {
  ROOT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
  if [[ -z "${TOOL:-}" ]]; then
    echo "TOOL must be provided to the test suite" >&2
    exit 1
  fi

  TOOL_METADATA_FILE="${ROOT_DIR}/tools/${TOOL}/tool.yaml"
  if [[ ! -f "${TOOL_METADATA_FILE}" ]]; then
    echo "Metadata file not found for tool '${TOOL}'" >&2
    exit 1
  fi
}

@test "test_boots_container" {
  run docker run --rm "${AICAGE_IMAGE}" /bin/bash -c "echo ${TOOL}-boot && whoami"
  [ "$status" -eq 0 ]
  [[ "$output" == *"${TOOL}-boot"* ]]
}

@test "test_agent_binary_present" {
  run docker run --rm "${AICAGE_IMAGE}" /bin/bash -c "command -v ${TOOL}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"${TOOL}"* ]]
}

@test "test_required_packages" {
  run docker run --rm "${AICAGE_IMAGE}" /bin/bash -c \
    "git --version >/dev/null && python3 --version >/dev/null && node --version >/dev/null && npm --version >/dev/null"
  [ "$status" -eq 0 ]
}
