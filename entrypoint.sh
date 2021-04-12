#!/bin/sh

if [ -z "$GIT_PAT" ]; then
    echo "Missing environment variable github token (GIT_PAT)"
    exit 1
fi
if [ -z "$GIT_OWNER" ]; then
    echo "Missing environment variable github repository owner (GIT_OWNER)"
    exit 1
fi
if [ -z "$GIT_REPO" ]; then
    echo "Missing environment variable github repository name (GIT_REPO)"
    exit 1
fi

# If a kubeconfig env var exists, set it as the default kubecofig
if [ -n "$KUBECONFIG_CONTENTS" ]; then
    mkdir -p ~/.kube
    echo "$KUBECONFIG_CONTENTS" > ~/.kube/config
fi


# The Github Action runner is installed in the entrypoint so that it always is running the latest version
# If the agent is installed in the docker container, a new version of the docker container needs to be published
# everytime a new version of the agent is released.
GIT_RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed -e 's/^v//g')
echo "latest version: ${GIT_RUNNER_VERSION}"
curl -Ls https://github.com/actions/runner/releases/download/v${GIT_RUNNER_VERSION}/actions-runner-linux-${RUNNER_PLATFORM}-${GIT_RUNNER_VERSION}.tar.gz | tar -zx

# Hacky workaround because the installation script doesn't include a flag for automation to not prompt a non-existent user
sed -i 's/\$apt_get install/DEBIAN_FRONTEND=noninteractive $apt_get install/g' ./bin/installdependencies.sh

# Run the dependency installation script
sudo ./bin/installdependencies.sh

REG_URL="https://api.github.com/repos/${GIT_OWNER}/${GIT_REPO}/actions/runners/registration-token"
echo "Requesting registration URL at '${REG_URL}'"

payload=$(curl -sX POST -H "Authorization: token ${GIT_PAT}" ${REG_URL})
export RUNNER_TOKEN=$(echo $payload | jq -r '.token')

./config.sh \
    --name $(hostname) \
    --token ${RUNNER_TOKEN} \
    --url https://github.com/${GIT_OWNER}/${GIT_REPO} \
    --work ${RUNNER_WORKDIR} \
    --labels ${LABELS} \
    --unattended \
    --replace

remove() {
    ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM
sleep 5
echo "./run.sh $*"
./run.sh "$*" &

wait $!