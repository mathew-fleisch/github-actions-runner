FROM mathewfleisch/tools:latest
LABEL maintainer="Mathew Fleisch <mathew.fleisch@gmail.com>"

ENV KUBECONFIG_CONTENTS ""
ENV GIT_PAT ""
ENV GIT_OWNER ""
ENV GIT_REPO ""
ENV LABELS "container-runner"
ENV RUNNER_WORKDIR "_work"
ENV ASDF_DATA_DIR=/opt/asdf

# Install asdf dependencies. See https://github.com/mathew-fleisch/tools for base container tools
USER github
WORKDIR /home/github
COPY --chown=github:github .tool-versions ./.tool-versions
COPY --chown=github:github pin ./pin
RUN rm -rf .git \
    && . ${ASDF_DATA_DIR}/asdf.sh \
    && asdf update
RUN . ${ASDF_DATA_DIR}/asdf.sh \
    && while IFS= read -r line; do asdf plugin add $(echo "$line" | awk '{print $1}'); done < .tool-versions
RUN . ${ASDF_DATA_DIR}/asdf.sh \
    && asdf install

# Source asdf and execute entrypoint
COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh
CMD /bin/sh -c ". ${ASDF_DATA_DIR}/asdf.sh && sudo chmod 666 /var/run/docker.sock && /home/github/entrypoint.sh"


