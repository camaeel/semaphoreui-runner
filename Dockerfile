ARG BASE_VERSION

FROM semaphoreui/runner:${BASE_VERSION}

# renovate: datasource=github-releases depName=terraform packageName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.11.0
# renovate: datasource=github-releases depName=packer packageName=hashicorp/packer
ARG PACKER_VERSION=1.12.0
# renovate: datasource=github-releases depName=opentofu packageName=opentofu/opentofu
ARG TOFU_VERSION=1.9.0
# renovate: datasource=github-releases depName=terragrunt packageName=gruntwork-io/terragrunt
ARG TERRAGRUNT_VERSION=0.78.0

ARG TARGETARCH

USER root

WORKDIR /tmp/packer

RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip && \
    unzip packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip -d /usr/local/bin && \
    rm packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip && \
    chmod +x /usr/local/bin/packer && \
    apk add tenv --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ && \
    tenv tf install && \
    tenv tg install ${TERRAGRUNT_VERSION} && \
    tenv tofu install ${TOFU_VERSION}

USER 1001

