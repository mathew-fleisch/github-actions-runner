# Github Actions Runner

A container definition for running the Github Actions agent. The agent is installed in the entrypoint so that it always runs the most up to date version, without having to build a new docker container.

## Build
[![Release CI: multi-arch container build & push](https://github.com/mathew-fleisch/github-actions-runner/actions/workflows/tag-release.yaml/badge.svg)](https://github.com/mathew-fleisch/github-actions-runner/actions/workflows/tag-release.yaml)
[![Update CI: asdf dependency versions](https://github.com/mathew-fleisch/github-actions-runner/actions/workflows/update-asdf-versions.yaml/badge.svg)](https://github.com/mathew-fleisch/github-actions-runner/actions/workflows/update-asdf-versions.yaml)
[Docker Hub](https://hub.docker.com/r/mathewfleisch/github-actions-runner/tags?page=1&ordering=last_updated)

Note: This build method requires the [buildx docker plugin.](https://github.com/docker/buildx) [See this link for more details...](https://smartling.com/resources/product/building-multi-architecture-docker-images-on-arm-64-bit-aws-graviton2/)
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t mathewfleisch/github-actions-runner:myversion .
```

See [this repo](https://github.com/mathew-fleisch/tools) for information about the base container.

## Run

```bash

# From Linux
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  -e GIT_PAT="$GIT_TOKEN" \
  -e GIT_OWNER="mathew-fleisch" \
  -e GIT_REPO="github-actions-runner" \
  -e LABELS="gha-runner" \
  --name "gha-runner" \
  mathewfleisch/github-actions-runner:v0.1.0

# From Mac
docker run -it --rm \
  -v /var/run/docker.sock:/var/rund/docker.sock \
  -e GIT_PAT="$GIT_TOKEN" \
  -e GIT_OWNER="mathew-fleisch" \
  -e GIT_REPO="github-actions-runner" \
  -e LABELS="gha-runner" \
  --name "gha-runner" \
  mathewfleisch/github-actions-runner:v0.1.0


```