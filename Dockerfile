# formbricks 5.1.4 with its Node.js binary replaced by the official 24.22.1 build.
# See README.md for why this exists and how to bump it.

# Same Alpine release line (3.23) as the formbricks base, so musl/libstdc++/libgcc match.
FROM node:24.22.1-alpine3.23@sha256:0468540aa58203ff9e40c2aab3907c52644ab818af6176b1c70a026137dc92a2 AS patched-node

FROM ghcr.io/formbricks/formbricks@sha256:d19d89770b1f56a80f869761db1f70fc10946adf4cf6b5380a80659f3bce6532

USER root
# Source binary is root:root 0755, same as the base.
COPY --from=patched-node --chown=root:root /usr/local/bin/node /usr/local/bin/node
RUN test "$(node --version)" = "v24.22.1"
USER nextjs
