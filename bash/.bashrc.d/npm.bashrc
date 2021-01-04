# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Node.js / NPM
#

export NODEJS_HOME=/usr/local/lib/node/nodejs
export PATH=$NODEJS_HOME/bin:$PATH

safewhich npm || return 0

#npm config set prefix ~/npm
#export PATH="$PATH:$HOME/npm/bin"
#export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"
