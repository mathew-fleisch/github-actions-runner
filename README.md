# Github Actions Runner

A container definition for running the Github Actions agent. The agent is installed in the entrypoint so that it always runs the most up to date version, without having to build a new docker container.

## Build

Note: If you intend on running these containers on an arm based system, they need to be built on an arm based system as well.
```bash
docker build -t gha-runner .
```

## Run

```bash
  # -e KUBECONFIG_CONTENTS="$(cat ~/.kube/config)"
  # -e ACTION_LABELS

# Platform runner will be on
platform="arm64"
# platform="x64"

docker run -it --rm \
  -e GIT_PAT="$GIT_TOKEN" \
  -e GIT_OWNER="mathew-fleisch" \
  -e GIT_REPO="github-actions-runner" \
  -e RUNNER_PLATFORM="arm64" \
  --name "gha-runner" \
  gha-runner:latest


docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  -e GIT_PAT="$GIT_TOKEN" \
  -e GIT_OWNER="mathew-fleisch" \
  -e GIT_REPO="github-actions-runner" \
  -e RUNNER_PLATFORM="arm64" \
  --name "gha-runner" \
  gha-runner:latest



```