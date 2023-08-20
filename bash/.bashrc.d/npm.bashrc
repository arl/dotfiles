# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Node.js / NPM
#
VERSION=v18.17.1
DISTRO=linux-x64

node_path=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/node
npm_path=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/npm

safewhich $node_path || return 0
safewhich $npm_path || return 0

NPM_PACKAGES="${HOME}/.npm-packages"
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

# Add "a few" things to the $PATH
export PATH="$PATH:/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$NPM_PACKAGES/bin"

# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
