# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Node.js / NPM
#

safewhich node || return 0
safewhich npm || return 0

NPM_PACKAGES="${HOME}/.npm-packages"

export PATH="$PATH:$NPM_PACKAGES/bin"

# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
