#!/usr/bin/env sh

set -x

NAME=${1:-prodguide-dev}
docker logs -f ${NAME}