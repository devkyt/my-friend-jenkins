# https://hub.docker.com/r/google/cloud-sdk
FROM --platform=linux/amd64 google/cloud-sdk:468.0.0-alpine

RUN gcloud components install kubectl && \
    set -eux && \
    apk add --update --no-cache python3 curl ca-certificates jq vim tar gpg

# https://github.com/helm/helm/releases
ARG HELM_VERSION

ENV HELM_SIGNATURE="https://github.com/helm/helm/releases/download/v${HELM_VERSION}/helm-v${HELM_VERSION}-linux-amd64.tar.gz.asc"
ENV HELM_URL="https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
ENV HELM_LOCAL_PATH='helm.tar.gz'

RUN curl https://keybase.io/mattfarina/pgp_keys.asc | gpg --import && \
    curl -L ${HELM_SIGNATURE} > ${HELM_LOCAL_PATH}.asc && \
    curl -L ${HELM_URL} > ${HELM_LOCAL_PATH} && \
    gpg --verify ${HELM_LOCAL_PATH}.asc ${HELM_LOCAL_PATH} && \
    tar xvzf ${HELM_LOCAL_PATH} && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    rm -f /var/cache/apk/*

ARG SENTRY_VERSION

RUN curl -sL https://sentry.io/get-cli/ | SENTRY_CLI_VERSION="${SENTRY_VERSION}" sh

# docker build \
#   --build-arg HELM_VERSION=3.14.3 \
#   --build-arg SENTRY_VERSION=2.31.0 \
#   -t eu.gcr.io/org/gcloud-toolkit:latest .


