#!/usr/bin/env sh
# Shared settings for the dev scripts. Uses podman if docker is not installed.
NAME=${NAME:-cnb-dev}
IMAGE=${IMAGE:-cnb-dev}
PORT=${PORT:-8000}
if [ -z "${ENGINE}" ]; then
  if command -v docker >/dev/null 2>&1; then ENGINE=docker; else ENGINE=podman; fi
fi
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
