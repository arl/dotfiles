# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# local stuff (machine-specific)
#

if safewhich atuin; then
    addToPATH $HOME/.atuin/bin
fi

export SSH_KEYS="$HOME/.ssh/id_ed25519"
export GOPATH=$HOME/dev
addToPATH $GOPATH/bin:$(go env GOROOT)/bin
export PATH
