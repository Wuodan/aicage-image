
set -euo pipefail

BASE="$1"

echo "Testing base: ${BASE}"

for dir in tools/*; do
  tool="$(basename "${dir}")"

  echo "Testing tool: ${tool}"

  scripts/util/build.sh --base "${BASE}" --tool ${tool} \
    || ( echo "Build tool ${tool} failed" && false )

  scripts/test.sh --image "aicage/aicage:${tool}-${BASE}-latest" --tool ${tool} \
    || ( echo "Testing tool ${tool} failed" && false )
done
