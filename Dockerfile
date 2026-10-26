# formbricks 6.1.1 with its Node.js binary replaced by the official 24.22.1 build.
# See README.md for why this exists and how to bump it.

# Same Alpine release line (3.23) as the formbricks base, so musl/libstdc++/libgcc match.
FROM node:24.22.1-alpine3.23@sha256:0468540aa58203ff9e40c2aab3907c52644ab818af6176b1c70a026137dc92a2 AS patched-node

FROM ghcr.io/formbricks/formbricks@sha256:c2f8ccfdf47a3d96c49fa4ae4d71d645c6eab0ce684aafb04519e3354a1d8811

USER root
# Source binary is root:root 0755, same as the base.
COPY --from=patched-node --chown=root:root /usr/local/bin/node /usr/local/bin/node
RUN test "$(node --version)" = "v24.22.1"
USER nextjs
