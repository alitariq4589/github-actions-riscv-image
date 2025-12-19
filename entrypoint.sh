#!/bin/bash
set -e

echo "=== GitHub Actions Runner Startup ==="

# --- DYNAMIC DOCKER GID MATCHING ---
# This is the key to solving your permission issues
DOCKER_SOCKET=/var/run/docker.sock

if [ -S "${DOCKER_SOCKET}" ]; then
    echo "Docker socket detected: ${DOCKER_SOCKET}"
    
    # Get the GID of the mounted docker socket
    DOCKER_GID=$(stat -c '%g' ${DOCKER_SOCKET})
    echo "Docker socket GID: ${DOCKER_GID}"
    
    # Check if a group with this GID already exists
    EXISTING_GROUP=$(getent group ${DOCKER_GID} | cut -d: -f1 || echo "")
    
    if [ -n "${EXISTING_GROUP}" ] && [ "${EXISTING_GROUP}" != "docker" ]; then
        echo "Group ${EXISTING_GROUP} already exists with GID ${DOCKER_GID}"
        echo "Removing it to create docker group..."
        groupdel ${EXISTING_GROUP} || true
    fi
    
    # Create or modify docker group with matching GID
    if getent group docker > /dev/null 2>&1; then
        echo "Docker group exists, modifying GID to ${DOCKER_GID}..."
        groupmod -g ${DOCKER_GID} docker
    else
        echo "Creating docker group with GID ${DOCKER_GID}..."
        groupadd -g ${DOCKER_GID} docker
    fi
    
    # Add runneruser to docker group
    echo "Adding runneruser to docker group..."
    usermod -aG docker runneruser
    
    # Verify
    echo "runneruser groups: $(groups runneruser)"
    
    # Test docker access as runneruser
    echo "Testing Docker access..."
    if su - runneruser -c "docker version" > /dev/null 2>&1; then
        echo "✓ Docker access confirmed!"
    else
        echo "⚠ Warning: Docker access test failed, but continuing..."
    fi
else
    echo "Warning: Docker socket not found at ${DOCKER_SOCKET}"
    echo "Docker commands will not work in this container"
fi

# --- GITHUB RUNNER CONFIGURATION ---
# Set runner name
RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"

echo "Configuring runner as user: runneruser"
cd /home/runner

# Now switch to runneruser and run the entire configuration/startup as that user
# IMPORTANT: Explicitly use bash, not sh (which doesn't support [[)
exec su - runneruser -c "/bin/bash <<'EOFSCRIPT'
    cd /home/runner
    
    if [[ ! -f .runner ]]; then
        if [[ -z '${GITHUB_REPO}' || -z '${RUNNER_TOKEN}' ]]; then
            echo 'Missing GITHUB_REPO or RUNNER_TOKEN'
            exit 1
        fi
        
        echo 'Registering runner: ${RUNNER_NAME}'
        ./config.sh \
            --url '${GITHUB_REPO}' \
            --token '${RUNNER_TOKEN}' \
            --name '${RUNNER_NAME}' \
            --unattended \
            --replace
    fi
    
    echo 'Starting GitHub Actions runner...'
    ./run.sh
EOFSCRIPT
"