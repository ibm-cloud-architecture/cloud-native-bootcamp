#!/usr/bin/env sh
# Follow the dev container logs.
. "$(dirname "$0")/common.sh"
${ENGINE} logs -f "${NAME}"
