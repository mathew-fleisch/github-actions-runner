# Github Actions Runner

A container definition for running the Github Actions agent. The agent is installed in the entrypoint so that it always runs the most up to date version, without having to build a new docker container.

## Build

Note: If you intend on running these containers on an arm based system, they need to be built on an arm based system as well.
```bash
docker build -t gha-runner .
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
  --name "gha-runner" \
  gha-runner:latest

# From Mac
docker run -it --rm \
  -v /var/run/docker.sock:/var/rund/docker.sock \
  -e GIT_PAT="$GIT_TOKEN" \
  -e GIT_OWNER="mathew-fleisch" \
  -e GIT_REPO="github-actions-runner" \
  --name "gha-runner" \
  mathewfleisch/github-actions-runner:latest


```