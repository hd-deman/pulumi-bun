ARG PULUMI_IMAGE=pulumi/pulumi-nodejs-26:3.273.0

FROM ${PULUMI_IMAGE}

USER root

ARG BUN_VERSION=1.4.4

ENV PULUMI_HOME=/pulumi-home \
    PULUMI_SKIP_UPDATE_CHECK=true \
    NODE_PATH=/opt/pulumi-deps/node_modules

RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL -o /tmp/bun.zip \
      "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-x64.zip" \
 && unzip -p /tmp/bun.zip bun-linux-x64/bun > /usr/local/bin/bun \
 && chmod 755 /usr/local/bin/bun \
 && rm -f /tmp/bun.zip \
 && bun --version

WORKDIR /opt/pulumi-deps

COPY package.json Pulumi.yaml ./
COPY sdks/yandex ./sdks/yandex

RUN npm install --ignore-scripts --no-audit --no-fund --no-package-lock \
      --registry https://registry.npmjs.org \
 && node sdks/yandex/scripts/postinstall.js \
 && pulumi plugin install resource kubernetes 4.34.2 \
 && pulumi plugin install resource terraform-provider 1.1.0
