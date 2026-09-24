#!/usr/bin/env sh
# Build the site in strict mode inside the dev container (same check CI runs).
set -e
. "$(dirname "$0")/common.sh"
${ENGINE} run --rm -v "${ROOT_DIR}:/docs" "${IMAGE}" build --strict --site-dir /tmp/site
