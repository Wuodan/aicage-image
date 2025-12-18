#!/usr/bin/env bash
set -euo pipefail

TOOL_DEFINITIONS_DIR="${ROOT_DIR}/tools"

_die() {
  if command -v die >/dev/null 2>&1; then
    die "$@"
  else
    echo "[common] $*" >&2
    exit 1
  fi
}

load_config_file() {
  local config_file="${ROOT_DIR}/config.yaml"
  [[ -f "${config_file}" ]] || _die "Config file not found: ${config_file}"

  while IFS=$'\t' read -r key value; do
    [[ -z "${key}" ]] && continue
    if [[ -z ${!key+x} ]]; then
      export "${key}=${value}"
    fi
  done < <(yq -er 'to_entries[] | [.key, (.value // "")] | @tsv' "${config_file}")
}

get_tool_field() {
  local tool="$1"
  local field="$2"
  local tool_dir="${TOOL_DEFINITIONS_DIR}/${tool}"
  local definition_file="${tool_dir}/tool.yaml"

  [[ -d "${tool_dir}" ]] || _die "Tool '${tool}' not found under ${TOOL_DEFINITIONS_DIR}"
  [[ -f "${definition_file}" ]] || _die "Missing tool.yaml for '${tool}'"

  local value
  value="$(yq -er ".${field}" "${definition_file}")" || _die "Failed to read ${field} from ${definition_file}"
  [[ -n "${value}" && "${value}" != "null" ]] || _die "${field} missing in ${definition_file}"
  printf '%s\n' "${value}"
}

# get anonymous pull token (public repo)
ghcr_pull_token() {
  local repo="$1"
  local token
  token="$(
    curl -fsSL \
      "${AICAGE_IMAGE_REGISTRY_API_TOKEN_URL}:${repo}:pull" \
    | jq -r '.token'
  )" || _die "Failed to get GHCR token"
  echo "$token"
}

ghcr_list_all_tags() {
  local repo="$1"
  local url="${AICAGE_IMAGE_REGISTRY_API_URL}/${repo}/tags/list?n=1000"
  local token resp body next

  # 1) get pull token
  token="$(ghcr_pull_token "$repo")"

  # 2) paginate
  while [[ -n "$url" ]]; do
    resp="$(
      curl -fsSL -i \
        -H "Authorization: Bearer ${token}" \
        "$url"
    )" || _die "GHCR query failed"

    # 2a) extract JSON body (after first empty line)
    body="$(sed '1,/^\r\{0,1\}$/d' <<<"$resp")"

    # 2b) output tags
    jq -r '.tags[]?' <<<"$body"

    # 2c) extract next-page URL from Link header (if any)
    next="$(sed -n 's/.*<\([^>]*\)>;[[:space:]]*rel="next".*/\1/pI' <<<"$resp")"

    url="$next"
  done
}

discover_base_aliases() {
  ghcr_list_all_tags "${AICAGE_IMAGE_BASE_REPOSITORY}" \
    | grep -E -- '-latest$' \
    | sed -E 's/(-amd64|-arm64)?-latest$//' \
    | sort -u
}
