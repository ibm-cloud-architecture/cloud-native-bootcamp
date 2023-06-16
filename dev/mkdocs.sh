#!/bin/sh

PORT=${1:-8000}

mkdocs serve --config-file "./mkdocs.yml" --livereload -a 127.0.0.1:${PORT}
