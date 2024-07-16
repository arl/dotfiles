# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# globals
#
EDITOR=nvim
TERM=xterm-256color

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
