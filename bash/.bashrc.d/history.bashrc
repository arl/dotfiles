#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# bash history
#

# Share history between different terminals
# The 3 next commands are taken from https://unix.stackexchange.com/questions/1288

# After each command, append to the history file and reread it
PROMPT_COMMAND="history -a; history -c; history -r;"

HISTCONTROL='ignoreboth:erasedups'

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# See HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=6000


# Declare histclean function. Look the whole history from duplicates, remove
# them, as well as entries matching HISTIGNORE, while preserving input order.
# From  https://stackoverflow.com/a/7449399/4515566

# remove duplicates while preserving input order
function __dedup {
   awk '! x[$0]++' "$@"
}

# removes $HISTIGNORE commands from input
function __rm_histignore {
   if [ -n "$HISTIGNORE" ]; then
      # replace : with |, then * with .*
      readonly IGNORE_PAT=$(echo "$HISTIGNORE" | sed s/\:/\|/g | sed s/\*/\.\*/g)
      # negated grep removes matches
      grep -vx "$IGNORE_PAT" $@
   else
      cat $@
   fi
}

# clean up the history file by remove duplicates and commands matching
# $HISTIGNORE entries
function histclean {
   local HISTFILE_SRC=~/.bash_history
   local HISTFILE_DST=/tmp/.$USER.bash_history.clean
   if [ -f $HISTFILE_SRC ]; then
      \cp $HISTFILE_SRC $HISTFILE_SRC.backup
      __dedup $HISTFILE_SRC | __rm_histignore >| $HISTFILE_DST
      \mv "${HISTFILE_DST}" "${HISTFILE_SRC}"
      chmod go-r $HISTFILE_SRC
      history -c
      history -r
   fi
}
