# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Node.js / NPM
#

if safewhich npm 
    then
    npm config set prefix ~/npm
    export PATH="$PATH:$HOME/npm/bin"
    export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"
fi
