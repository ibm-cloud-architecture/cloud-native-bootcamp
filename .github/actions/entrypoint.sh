#!/usr/bin/env sh

cd "${GITHUB_WORKSPACE}"

# Python Dependencies
pip install -r requirements.txt
# NodeJS Dependencies
npm ci

npm run build