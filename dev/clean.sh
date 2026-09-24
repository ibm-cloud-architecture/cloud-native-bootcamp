#!/usr/bin/env sh
# Remove the dev container.
. "$(dirname "$0")/common.sh"
${ENGINE} rm --force "${NAME}" >/dev/null 2>&1
echo "Removed container '${NAME}' (if it existed)"
