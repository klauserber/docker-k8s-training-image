FROM ubuntu:22.04

ARG TARGETARCH=amd64
ARG TARGETOS=linux

ENV LP_HOSTNAME_ALWAYS=-1

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
    liquidprompt \
 && rm -rf /var/lib/apt/lists/*

# https://hub.docker.com/_/docker/tags
COPY --from=docker:24.0.6-cli /usr/local/bin/docker /usr/local/bin/docker-compose /usr/local/bin/
# https://hub.docker.com/r/docker/buildx-bin/tags
COPY --from=docker/buildx-bin:0.11.2 /buildx /usr/libexec/docker/cli-plugins/docker-buildx

RUN curl -s https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.13.1
RUN set -e; \
  cd /tmp; \
  curl -Ss -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz; \
  tar xzf helm.tar.gz; \
  mv ${TARGETOS}-${TARGETARCH}/helm /usr/local/bin/; \
  chmod +x /usr/local/bin/helm; \
  rm -rf ${TARGETOS}-${TARGETARCH} helm.tar.gz

# https://github.com/kubernetes/kubernetes/releases
ARG KUBECTL_VERSION=1.28.2
RUN set -e; \
    cd /tmp; \
    curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl"; \
    mv kubectl /usr/local/bin/; \
    chmod +x /usr/local/bin/kubectl

# https://github.com/derailed/k9s/releases
ARG K9S_VERSION=0.27.4
RUN set -e; \
  mkdir -p /tmp/k9s; \
  cd /tmp/k9s; \
  curl -LSs -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz; \
  tar xzf k9s.tar.gz; \
  mv k9s /usr/local/bin/; \
  cd /tmp; \
  rm -rf k9s

# https://github.com/bitnami-labs/sealed-secrets/releases
ARG KUBESEAL_VERSION=0.24.1
RUN set -e; \
  wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz; \
  tar -xvzf kubeseal-${KUBESEAL_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz kubeseal; \
  install -m 755 kubeseal /usr/local/bin/kubeseal

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