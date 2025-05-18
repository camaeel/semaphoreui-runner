# renovate: datasource=github-releases depName=semaphoreui packageName=semaphoreui/semaphore
ARG BASE_VERSION=v2.14.10

FROM semaphoreui/runner:${BASE_VERSION}

# renovate: datasource=github-releases depName=terraform packageName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.3.0
# renovate: datasource=github-releases depName=packer packageName=hashicorp/packer
ARG PACKER_VERSION=1.12.0
# renovate: datasource=github-releases depName=opentofu packageName=opentofu/opentofu
ARG TOFU_VERSION=1.9.1
# renovate: datasource=github-releases depName=terragrunt packageName=gruntwork-io/terragrunt
ARG TERRAGRUNT_VERSION=0.78.4

ARG TARGETARCH
#ARG TENV_GITHUB_TOKEN

USER root

WORKDIR /tmp/packer

RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip && \
    unzip packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip -d /usr/local/bin && \
    rm packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip && \
    chmod +x /usr/local/bin/packer && \
    rm /usr/local/bin/terraform /usr/local/bin/tofu && \
    apk add tenv --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ && \
    apk add aws-cli

USER 1001

RUN tenv tf install && \
    tenv tg install ${TERRAGRUNT_VERSION} && \
    tenv tofu install ${TOFU_VERSION}

ENV TENV_AUTO_INSTALL=true

WORKDIR /home/semaphore

