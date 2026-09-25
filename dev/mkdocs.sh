#!/usr/bin/env sh
# Serve the site locally without a container (requires: pip install -r requirements.txt).
PORT=${1:-8000}
mkdocs serve --livereload -a "127.0.0.1:${PORT}"
