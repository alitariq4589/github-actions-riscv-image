#!/bin/bash
set -e

if [[ ! -f ".runner" ]]; then
  if [[ -z "$GITHUB_REPO" || -z "$RUNNER_TOKEN" ]]; then
    echo "Missing GITHUB_REPO or RUNNER_TOKEN"
    exit 1
  fi
  ./config.sh \
    --url "${GITHUB_REPO}" \
    --token "${RUNNER_TOKEN}" \
    --unattended \
    --replace
fi

while true; do
  echo "Starting GitHub runner via run.sh..."
  ./run.sh

  # If run.sh exits (e.g., job finished or crash), wait and restart
  echo "Runner stopped. Restarting in 3 seconds..."
  sleep 3
done
