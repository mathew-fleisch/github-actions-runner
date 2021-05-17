FROM ubuntu:20.04
LABEL maintainer="Mathew Fleisch <mathew.fleisch@gmail.com>"

ENV KUBECONFIG_CONTENTS ""
ENV GIT_PAT ""
ENV GIT_OWNER ""
ENV GIT_REPO ""
ENV LABELS "container-runner"
ENV RUNNER_WORKDIR "_work"
COPY getArch /usr/local/bin/getArch
ENV ASDF_DATA_DIR=/opt/asdf
WORKDIR $ASDF_DATA_DIR

# Install apt dependencies, asdf, and set up github user
RUN rm /bin/sh && ln -s /bin/bash /bin/sh \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y curl wget apt-utils python3 python3-pip make build-essential openssl lsb-release libssl-dev apt-transport-https ca-certificates iputils-ping git vim jq zip sudo binfmt-support qemu-user-static \
    && curl -sSL https://get.docker.com/ | sh \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && apt-get clean \
    && apt-get dist-upgrade -u -y \
    && useradd -ms /bin/bash github \
    && usermod -aG sudo github \
    && addgroup runners \
    && adduser github runners \
    && adduser github docker \
    && usermod -aG docker github \
    && mkdir -p $ASDF_DATA_DIR \
    && chown -R github:runners $ASDF_DATA_DIR \
    && chmod -R g+w $ASDF_DATA_DIR \
    && git clone https://github.com/asdf-vm/asdf.git ${ASDF_DATA_DIR} --branch v0.8.0 \
    && echo "export ASDF_DATA_DIR=${ASDF_DATA_DIR}" | tee -a /home/github/.bashrc \
    && echo ". ${ASDF_DATA_DIR}/asdf.sh" | tee -a /home/github/.bashrc \
    && mkdir -p ~/.docker/cli-plugins \
    && wget $(curl -s https://api.github.com/repos/docker/buildx/releases/latest | jq -r .assets[].browser_download_url | grep $(getArch) | grep -v darwin) -O ~/.docker/cli-plugins/docker-buildx \
    && chmod +x ~/.docker/cli-plugins/docker-buildx \
    && cp -r ~/.docker /home/github/. \
    && chown -R github:github /home/github/.docker \
    && docker buildx create --name mbuilder \
    && docker buildx use mbuilder \
    && docker buildx inspect --bootstrap

# Install asdf dependencies
USER github
WORKDIR /home/github
COPY .tool-versions /home/github/.
RUN . ${ASDF_DATA_DIR}/asdf.sh  \
    && asdf plugin add awscli \
    && asdf plugin add golang \
    && asdf plugin add helm \
    && asdf plugin add helmfile \
    && asdf plugin add k9s \
    && asdf plugin add kubectl \
    && asdf plugin add kubectx \
    && asdf plugin add shellcheck \
    && asdf plugin add terraform \
    && asdf plugin add terragrunt \
    && asdf plugin add tflint \
    && asdf plugin add yq \
    && asdf install \
    && docker buildx create --name mbuilder \
    && docker buildx use mbuilder \
    && docker buildx inspect --bootstrap


# Source asdf and execute entrypoint
COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh
CMD /bin/sh -c ". ${ASDF_DATA_DIR}/asdf.sh && sudo chmod 666 /var/run/docker.sock && /home/github/entrypoint.sh"



