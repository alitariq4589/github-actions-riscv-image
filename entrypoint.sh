#!/bin/bash

set -e

# Set runner name
RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"

# Execute only if .runner file does not exist
if [[ ! -f ".runner" ]]; then
  if [[ -z "$GITHUB_REPO" || -z "$RUNNER_TOKEN" ]]; then
    echo "Missing GITHUB_REPO or RUNNER_TOKEN"
    exit 1
  fi

  ./config.sh \
    --url "${GITHUB_REPO}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --unattended \
    --replace
fi

# Start the runner
./run.sh