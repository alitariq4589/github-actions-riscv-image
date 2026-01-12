#!/bin/bash
set -e

if [[ -z "$GITHUB_REPO" || -z "$RUNNER_TOKEN" ]]; then
  echo "Missing GITHUB_REPO or RUNNER_TOKEN"
  exit 1
fi

# Always configure with --replace to clear any stale sessions
./config.sh \
  --url "${GITHUB_REPO}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --unattended \
  --replace

# Keep the runner alive and restart it if it crashes
while true; do
  echo "=== Starting runner at $(date) ==="
  ./run.sh
  EXIT_CODE=$?
  
  echo "=== Runner exited with code $EXIT_CODE at $(date) ==="
  
  # Check diagnostic logs
  if [[ -f "_diag/Runner_*.log" ]]; then
    echo "=== Last 50 lines of Runner diagnostic log ==="
    tail -n 50 _diag/Runner_*.log | tail -n 50
  fi
  
  if [[ -f "_diag/Worker_*.log" ]]; then
    echo "=== Last 50 lines of Worker diagnostic log ==="
    tail -n 50 _diag/Worker_*.log | tail -n 50
  fi
  
  echo "Waiting 10 seconds before restart..."
  sleep 10
done
