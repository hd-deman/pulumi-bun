# pulumi-bun

CI image for Pulumi programs that run on Bun.

Base image: `pulumi/pulumi-nodejs-26:3.273.0`. The build adds:

- Bun 1.4.4 on `PATH`
- Node dependencies from `package.json`, including the Yandex provider SDK generated from `registry.terraform.io/yandex-cloud/yandex` 0.239.0
- Pulumi plugins: `kubernetes` 4.34.2 and `terraform-provider` 1.1.0

`NODE_PATH` is `/opt/pulumi-deps/node_modules`. Plugins are stored in `/pulumi-home`.

## Image

GitHub Actions publishes:

- `ghcr.io/hd-deman/pulumi-bun:3.273.0-1`
- `ghcr.io/hd-deman/pulumi-bun:latest`

`3.273.0-1` vendors `terraform-provider-yandex` 0.239.0 at `/opt/terraform-providers/terraform-provider-yandex` and points the SDK at that file.

The tag matches the Pulumi CLI in the base image.

## Build

A push to `main` runs the `image` workflow. You can also start it by hand from the Actions tab.
