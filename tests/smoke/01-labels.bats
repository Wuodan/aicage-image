#!/usr/bin/env bats

setup() {
  ROOT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
  # shellcheck source=../../scripts/common.sh
  source "${ROOT_DIR}/scripts/common.sh"
  load_config_file
  EXPECTED_TOOL_PATH="$(get_tool_field "${TOOL}" tool_path)"
  EXPECTED_TOOL_FULL_NAME="$(get_tool_field "${TOOL}" tool_full_name)"
  EXPECTED_TOOL_HOMEPAGE="$(get_tool_field "${TOOL}" tool_homepage)"
}

@test "image labels include base metadata" {
  run docker image inspect \
    --format '{{ index .Config.Labels "org.aicage.tool.tool_path" }}' \
    "${AICAGE_IMAGE}"
  [ "$status" -eq 0 ]
  [ "$output" = "${EXPECTED_TOOL_PATH}" ]

  run docker image inspect \
    --format '{{ index .Config.Labels "org.aicage.tool.tool_full_name" }}' \
    "${AICAGE_IMAGE}"
  [ "$status" -eq 0 ]
  [ "$output" = "${EXPECTED_TOOL_FULL_NAME}" ]

  run docker image inspect \
    --format '{{ index .Config.Labels "org.aicage.tool.tool_homepage" }}' \
    "${AICAGE_IMAGE}"
  [ "$status" -eq 0 ]
  [ "$output" = "${EXPECTED_TOOL_HOMEPAGE}" ]

  run docker image inspect \
    --format '{{ index .Config.Labels "org.opencontainers.image.description" }}' \
    "${AICAGE_IMAGE}"
  [ "$status" -eq 0 ]
  [ "$output" = "Agent image for ${TOOL}" ]
}
