FROM mathewfleisch/tools:v0.3.3
# based on: ubuntu:22.04 https://github.com/mathew-fleisch/tools
LABEL maintainer="Mathew Fleisch <mathew.fleisch@gmail.com>"

ENV KUBECONFIG_CONTENTS ""
ENV GIT_PAT ""
ENV GIT_OWNER ""
ENV GIT_REPO ""
ENV PING ""
ENV LABELS "container-runner"
ENV RUNNER_WORKDIR "_work"
ENV ASDF_DATA_DIR=/opt/asdf

# Install asdf dependencies. See https://github.com/mathew-fleisch/tools for base container tools
USER github
WORKDIR /home/github
COPY --chown=github:github .tool-versions ./.tool-versions
COPY --chown=github:github pin ./pin
RUN sudo chown github:github -R ${ASDF_DATA_DIR} \
    && . ${ASDF_DATA_DIR}/asdf.sh \
    && asdf update \
    && cat .tool-versions \
        | grep -vE '^#' \
        | awk '{print $1}' \
        | sort \
        | uniq \
        | xargs -I {} asdf plugin add {} || true \
    && asdf install

# Source asdf and execute entrypoint
COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh 
ENTRYPOINT /home/github/entrypoint.sh


