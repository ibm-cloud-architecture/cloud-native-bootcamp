#!/usr/bin/env sh

set -x

NAME=${1:-prodguide-dev}
PORT=${2:-8000}
IMAGE=${3:-prodguide-dev}

docker run --name "${NAME}" -d -p "${PORT}:${PORT}" -v "${PWD}:/site" ${IMAGE} serve --dirtyreload --dev-addr=0.0.0.0:${PORT}
echo "Dev environment running with live reloading enabled. Open http://localhost:${PORT} to see the site"
echo "For live logs run:"
echo "docker logs -f ${NAME}"
