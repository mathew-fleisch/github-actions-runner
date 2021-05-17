# Github Actions Runner

A container definition for running the Github Actions agent. The agent is installed in the entrypoint so that it always runs the most up to date version, without having to build a new docker container.

## Build

Note: This build method requires the [buildx docker plugin.](https://github.com/docker/buildx) [See this link for more details...](smartling.com/resources/product/building-multi-architecture-docker-images-on-arm-64-bit-aws-graviton2/)
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t mathewfleisch/github-actions-runner:myversion .
```

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