#!/usr/bin/env sh
# Build the dev container image.
set -e
. "$(dirname "$0")/common.sh"
${ENGINE} build -t "${IMAGE}" -f "${SCRIPT_DIR}/Dockerfile" "${ROOT_DIR}"
