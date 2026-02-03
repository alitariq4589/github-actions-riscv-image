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

If you would like to use docker in docker support, you can fetch the image from tag `docker-ubuntu-latest` and use following command. This spawns new containers using the host container sockets and is ideal for using docker in docker with full cpu usage.

```shell
docker run -d \
    --restart=always \
    --privileged \
    --network=host \
    --security-opt seccomp=unconfined \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e GITHUB_REPO="$REPO_LINK" \
    -e RUNNER_TOKEN="$REPO_TOKEN$" \
    -e RUNNER_NAME="$(hostname)-docker-runner" \
    -e DOCKER_ENABLED="true" \
    -e RUNNER_LABELS="riscv64_runner" \
    --name="$CONTAINER_NAME" \
    docker.io/cloudv10x/github-actions-riscv:docker-latest
```

Note: The `--network=host` is added because it is noted that sometimes the docker container has dns issues and refuses to connect to sites like `github.com`. You can remove it if works fine for you without it.