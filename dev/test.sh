#!/usr/bin/env sh

set -x

NAME=${1:-prodguide-dev}
PORT=${2:-8000}
IMAGE=${3:-prodguide-dev}

docker run --rm -v "${PWD}:/site" -it --entrypoint "" ${IMAGE} ./build.sh
