#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Bash completion
#

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi