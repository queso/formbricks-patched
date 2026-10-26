# formbricks-patched

`ghcr.io/queso/formbricks-patched:6.1.1-node24.22.1` is the upstream formbricks 6.1.1 image
(`ghcr.io/formbricks/formbricks@sha256:c2f8ccfdf47a3d96c49fa4ae4d71d645c6eab0ce684aafb04519e3354a1d8811`)
with one change: `/usr/local/bin/node` is replaced by the official Node.js 24.22.1 binary.
Everything else (app files, entrypoint, `CMD`, `USER nextjs`, workdir, npm/corepack) is the
upstream image unchanged.

## Why

Node.js released security fixes on 2026-10-21 (10 CVEs, including CVE-2026-111497, an
out-of-bounds write in the Brotli decoder that can lead to RCE). The newest upstream release
(6.1.1) still ships Node 24.21.0, so this image supplies the patched runtime.

Earlier tag: `5.1.4-node24.22.1` (formbricks 5.1.4, upstream Node 24.17.0), built from commit
a8e2fca. It stays in GHCR as the rollback image for the 5.1.4 database schema.

Swapping only the binary is safe because it stays on Node 24 (same native-module ABI). The
native addons in the image are `sharp` and `lightningcss`, both Node-API builds.

## Library compatibility

The base image is Alpine 3.23.7 (musl 1.2.5, libstdc++/libgcc 15.2.0-r2). The node binary
is dynamically linked against musl, `libstdc++.so.6` and `libgcc_s.so.1`. The default
`node:24.22.1-alpine` tag is Alpine 3.24 (musl 1.2.6), so the binary is taken from
`node:24.22.1-alpine3.23` instead, whose libraries match the base package versions.

## Rebuilding for the next Node patch

1. Find the new `node:<version>-alpine3.23` tag (or the Alpine line matching the base image:
   check with `docker run --rm --entrypoint cat <base> /etc/alpine-release`) and its digest:
   `docker buildx imagetools inspect node:<version>-alpine3.23`.
2. Update the `FROM ... AS patched-node` line and the `test` version in `Dockerfile`.
3. Update `TAG` and `NODE_VERSION` in `.github/workflows/publish.yaml`.
4. Push to `main`. The workflow builds `linux/amd64`, checks `node --version`, loads `sharp` and `lightningcss`,
   runs a Brotli round-trip, then pushes `:<TAG>` and `:<TAG>-<shortsha>`.

Retire this repo once formbricks is upgraded to a release that ships a patched Node.
