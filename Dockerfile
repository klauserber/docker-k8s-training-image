FROM ubuntu:22.04

ARG TARGETARCH=amd64
ARG TARGETOS=linux

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y \
    ca-certificates \
    software-properties-common \
    curl \
    wget \
    unzip \
    iputils-ping \
    sudo \
    git \
    vim \
    jq \
    ssh \
    pkg-config \
    dnsutils \
    iproute2 \
    pwgen \
    gettext-base \
    bash-completion \
    sipcalc \
 && rm -rf /var/lib/apt/lists/*

ARG DOCKER_CLI_VERSION=20.10-cli
COPY --from=docker:20.10-cli /usr/local/bin/docker /usr/local/bin/docker-compose /usr/local/bin/

RUN curl -s https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

ARG HELM_VERSION=3.10.3
RUN set -e; \
  cd /tmp; \
  curl -Ss -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz; \
  tar xzf helm.tar.gz; \
  mv ${TARGETOS}-${TARGETARCH}/helm /usr/local/bin/; \
  chmod +x /usr/local/bin/helm; \
  rm -rf ${TARGETOS}-${TARGETARCH} helm.tar.gz

ARG KUBECTL_VERSION=1.24.9
RUN set -e; \
    cd /tmp; \
    curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl"; \
    mv kubectl /usr/local/bin/; \
    chmod +x /usr/local/bin/kubectl


# Install buildx
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

ARG CODE_SERVER_VERSION=4.9.1
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

ARG K9S_VERSION=0.26.7
RUN set -e; \
  mkdir -p /tmp/k9s; \
  cd /tmp/k9s; \
  if [ ${TARGETARCH} = amd64 ]; then TARGETARCH=x86_64; fi; \
  curl -LSs -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz; \
  tar xzf k9s.tar.gz; \
  mv k9s /usr/local/bin/; \
  cd /tmp; \
  rm -rf k9s

COPY helpers /helpers

RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --uid=1000 \
      --user-group && \
      echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

RUN mkdir /run/sshd


COPY bashrc.sh /tmp/
RUN set -e; \
  cat /tmp/bashrc.sh >> /etc/bash.bashrc; \
  rm /tmp/bashrc.sh

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en

USER coder

RUN touch ${HOME}/.bashrc

ENV PATH=${HOME}/.local/bin:${HOME}/bin:${PATH}

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en