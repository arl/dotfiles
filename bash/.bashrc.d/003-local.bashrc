# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# local stuff (machine-specific)
#

if safewhich atuin; then
    export PATH="$HOME/.atuin/bin:$PATH"
fi

export SSH_KEYS="$HOME/.ssh/id_ed25519"
export GOPATH=$HOME/dev
PATH=$GOPATH/bin:$(go env GOROOT)/bin:$PATH
export PATH
