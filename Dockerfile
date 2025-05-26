# renovate: datasource=github-releases depName=semaphoreui packageName=semaphoreui/semaphore
ARG BASE_VERSION=v2.14.10

FROM semaphoreui/runner:${BASE_VERSION}

# renovate: datasource=github-releases depName=terraform packageName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.12.1
# renovate: datasource=github-releases depName=packer packageName=hashicorp/packer
ARG PACKER_VERSION=1.12.0
# renovate: datasource=github-releases depName=opentofu packageName=opentofu/opentofu
ARG TOFU_VERSION=1.9.1
# renovate: datasource=github-releases depName=terragrunt packageName=gruntwork-io/terragrunt
ARG TERRAGRUNT_VERSION=0.80.2
# renovate: datasource=github-releases depName=aws_signing_helper packageName=aws/rolesanywhere-credential-helper
ARG AWS_SIGNING_HELPER_VERSION=1.6.0
# renovate: datasource=github-releases depName=talosctl packageName=siderolabs/talos
ARG TALOS_VERSION=1.10.2

ARG TARGETARCH

USER root

WORKDIR /tmp/packer

RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip && \
    unzip packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip -d /usr/local/bin && \
    rm packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip && \
    chmod +x /usr/local/bin/packer && \
    rm /usr/local/bin/terraform /usr/local/bin/tofu && \
    apk add tenv --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ && \
    # gcompat is needed for aws_signing_helper to work
    apk add aws-cli gcompat && \
    case "${TARGETARCH}" in \
      amd64)  export AWS_ARCH="X86_64" ;; \
      arm64)  export AWS_ARCH="Aarch64" ;; \
      *)      echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    wget https://rolesanywhere.amazonaws.com/releases/${AWS_SIGNING_HELPER_VERSION}/${AWS_ARCH}/Linux/aws_signing_helper -O /usr/local/bin/aws_signing_helper && \
    chmod a+x /usr/local/bin/aws_signing_helper

WORKDIR /usr/local/bin/

RUN wget https://github.com/siderolabs/talos/releases/download/v${TALOS_VERSION}/talosctl-linux-${TARGETARCH} -O /usr/local/bin/talosctl-linux-${TARGETARCH} && \
    chmod a+x /usr/local/bin/talosctl-linux-${TARGETARCH} && \
    curl -L https://github.com/siderolabs/talos/releases/download/v${TALOS_VERSION}/sha512sum.txt | grep talosctl-linux-${TARGETARCH} | sha512sum -c - && \
    mv /usr/local/bin/talosctl-linux-${TARGETARCH} /usr/local/bin/talosctl

USER 1001

ENV TENV_AUTO_INSTALL=true
ENV TENV_ROOT=/home/semaphore/.tenv

RUN --mount=type=secret,id=TENV_GITHUB_TOKEN,env=TENV_GITHUB_TOKEN \
    tenv tf install && \
    tenv tg install ${TERRAGRUNT_VERSION} && \
    tenv tofu install ${TOFU_VERSION}

WORKDIR /home/semaphore

