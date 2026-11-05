# pulumi-bun

CI image for Pulumi programs that run on Bun.

Base image: `pulumi/pulumi-nodejs-26:3.274.0`. Bun comes from that image. The build adds:

- Node dependencies from `package.json`, including the Yandex provider SDK generated from `registry.terraform.io/yandex-cloud/yandex` 0.239.0
- Pulumi plugins: `kubernetes` 4.34.2 and `terraform-provider` 1.1.0

`NODE_PATH` is `/opt/pulumi-deps/node_modules`. Plugins are stored in `/pulumi-home`. The container process is the `node` user.

## Image

GitHub Actions publishes:

- `ghcr.io/hd-deman/pulumi-bun:3.274.0-1`
- `ghcr.io/hd-deman/pulumi-bun:latest`

`3.274.0-1` vendors `terraform-provider-yandex` 0.239.0 at `/opt/terraform-providers/terraform-provider-yandex` and points the SDK at that file.

The Pulumi CLI in the image is 3.274.0. The suffix is a new tag so a runner that already pulled `3.274.0` does not keep that copy.

## Build

A push to `main` runs the `image` workflow. You can also start it by hand from the Actions tab.
