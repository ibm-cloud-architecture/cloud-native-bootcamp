#!/usr/bin/env sh
# Serve the site with live reload from the dev container.
set -e
. "$(dirname "$0")/common.sh"
"${SCRIPT_DIR}/clean.sh"
${ENGINE} run --name "${NAME}" -d -p "${PORT}:8000" -v "${ROOT_DIR}:/docs" "${IMAGE}" serve --livereload --dev-addr=0.0.0.0:8000
echo "Dev server running at http://localhost:${PORT} (logs: npm run dev:logs)"
