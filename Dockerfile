FROM mathewfleisch/tools:latest
LABEL maintainer="Mathew Fleisch <mathew.fleisch@gmail.com>"

ENV KUBECONFIG_CONTENTS ""
ENV GIT_PAT ""
ENV GIT_OWNER ""
ENV GIT_REPO ""
ENV LABELS "container-runner"
ENV RUNNER_WORKDIR "_work"
ENV ASDF_DATA_DIR=/opt/asdf
WORKDIR $ASDF_DATA_DIR

# Install asdf dependencies. See https://github.com/mathew-fleisch/tools for base container tools
USER github
WORKDIR /home/github
COPY --chown=github:github .tool-versions ./.tool-versions
COPY --chown=github:github pin ./pin
COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh \
    && . ${ASDF_DATA_DIR}/asdf.sh  \
    && asdf update \
    && while IFS= read -r line; do dep=$(echo "$line" | sed 's/\ .*//g'); asdf plugin add $dep; done < .tool-versions \
    && asdf install

# Source asdf and execute entrypoint
CMD /bin/sh -c ". ${ASDF_DATA_DIR}/asdf.sh && sudo chmod 666 /var/run/docker.sock && /home/github/entrypoint.sh"


