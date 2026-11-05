ARG PULUMI_IMAGE=pulumi/pulumi-nodejs-26:3.274.0

FROM ${PULUMI_IMAGE}

# The base image is root and has no USER. apt-get and the writes under
# /opt and /pulumi-home need root. The job process is the node user that
# already exists in the Node base image.

ENV PULUMI_HOME=/pulumi-home \
    PULUMI_SKIP_UPDATE_CHECK=true \
    NODE_PATH=/opt/pulumi-deps/node_modules

WORKDIR /opt/pulumi-deps

COPY package.json bun.lock Pulumi.yaml ./
COPY sdks/yandex ./sdks/yandex

# bun install, not npm. bun.lock is the transio lock: its tarball URLs
# pointed at a local proxy, so they are rewritten to registry.npmjs.org.
# --frozen-lockfile keeps those versions. --ignore-scripts: pulumi package
# add rewrites sdks/yandex, so the SDK postinstall runs after that.
# --linker hoisted: CI symlinks this node_modules onto the checkout, which
# needs a normal layout rather than Bun's isolated one.
RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip \
 && rm -rf /var/lib/apt/lists/* \
 && bun --version \
 && bun install --ignore-scripts --linker hoisted --frozen-lockfile \
      --registry https://registry.npmjs.org \
 && pulumi plugin install resource kubernetes 4.34.2 \
 && pulumi plugin install resource terraform-provider 1.1.0 \
 && mkdir -p /opt/terraform-providers \
 && curl -fsSL -o /tmp/yandex.zip \
      https://github.com/yandex-cloud/terraform-provider-yandex/releases/download/v0.239.0/terraform-provider-yandex_0.239.0_linux_amd64.zip \
 && unzip -p /tmp/yandex.zip terraform-provider-yandex_v0.239.0 > /opt/terraform-providers/terraform-provider-yandex \
 && chmod 755 /opt/terraform-providers/terraform-provider-yandex \
 && rm -f /tmp/yandex.zip \
 && pulumi package add terraform-provider /opt/terraform-providers/terraform-provider-yandex --non-interactive \
 && PATH="/opt/pulumi-deps/node_modules/.bin:${PATH}" node sdks/yandex/scripts/postinstall.js \
 && chown -R node:node /opt/pulumi-deps /pulumi-home /opt/terraform-providers

USER node
