# GitHub Actions RISC-V Images

This repository is for build and sending the images of GitHub actions to dockerhub. The images will be pushed to https://hub.docker.com/r/cloudv10x/github-actions-riscv

The source code for github actions runner for RISC-V: https://github.com/alitariq4589/github-runner-riscv

## How to use this image

If you would like to use this image for docker/podman directly, use the following command on a RISC-V linux compute machine.


```
podman run -d \
    --restart=always \
    -e GITHUB_REPO="<YOUR_REPO_URL>" \
    -e RUNNER_TOKEN="<YOUR_REPO_RUNNER_TOKEN>" \
    -e RUNNER_NAME="$(hostname)-runner-1" \
    --security-opt seccomp=unconfined  \
    docker.io/cloudv10x/github-actions-riscv
```

The `<YOUR_REPO_URL>` and `<YOUR_REPO_RUNNER_TOKEN>` can be obtained from your repository settings under `Settings > Actions > Runner > New self-hosted runner`