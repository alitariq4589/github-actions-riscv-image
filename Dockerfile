FROM docker.io/riscv64/debian:trixie
RUN apt-get update && apt-get install -y curl git ca-certificates libicu-dev sudo libatomic1 git gawk jq
WORKDIR /home/runner

ARG RUNNER_VERSION=2.328.0

# Download GitHub runner (replace URL with the latest for your architecture)

# Download
RUN set -ex && curl -L -O https://github.com/alitariq4589/github-runner-riscv/releases/download/v${RUNNER_VERSION}_riscv/actions-runner-linux-riscv64-${RUNNER_VERSION}.tar.gz

# Extract
RUN set -ex && tar -xvzf actions-runner-linux-riscv64-${RUNNER_VERSION}.tar.gz

# Cleanup
RUN set -ex && rm actions-runner-linux-riscv64-${RUNNER_VERSION}.tar.gz


    # Install dependencies for the runner (if any)
RUN set -ex bash ./bin/installdependencies.sh

# Copy entrypoint script
COPY entrypoint.sh .
RUN set -ex chmod +x entrypoint.sh

# Add a user which will run the github actions
RUN set -ex && useradd -m runneruser
RUN set -ex && chown -R runneruser:runneruser /home/runner

# Add runneruser to sudoers without password prompt
RUN set -ex echo "runneruser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/runneruser
USER runneruser
ENTRYPOINT ["./entrypoint.sh"]