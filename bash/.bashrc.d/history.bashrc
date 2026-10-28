#!/bin/bash
# vim: set ft=sh ts=3 sw=2 sts=2 et sta:
#
__use_vanilla_history() {
  :
}

__use_atuin() {
  . "$HOME/.atuin/bin/env"
  eval "$(atuin init bash)"
}

# Share history between different terminals
__use_shared_history() {
  # After each command, append to the history file and reread it.
  PROMPT_COMMAND="history -a; history -c; history -r;"

  HISTCONTROL='ignoreboth:erasedups'

  # When shell exits, append to the history file instead of overwriting it.
  shopt -s histappend

  # See HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=2000
  HISTFILESIZE=6000
}

__in_vscode() {
  [[ ${TERM_PROGRAM-} == vscode || -n ${VSCODE_SHELL_INTEGRATION-} ]]
}

addToPATH "$HOME/.atuin/bin"

if   __in_vscode;          then __use_vanilla_history
elif safewhich atuin;      then __use_atuin
else                            __use_shared_history
fi
