#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# If installed, let github.com/ellie/atuin handle history management, otherwise,
# use old-scholl bash hisotry management configuration.
if safewhich atuin; then
   [[ -f ~/.bash-preexec.sh ]] && source "$HOME/.bash-preexec.sh"
   # Bind ctrl-r but not up arrow
   # eval "$(atuin init --disable-up-arrow bash)"
   # return

   # replace the default:
   # [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
   # eval "$(atuin init bash)"

   # with this:
   [[ -f ~/.bash-preexec.sh ]] && source "$HOME/.bash-preexec.sh"
   eval "$(atuin init bash --disable-up-arrow)"

   export ATUIN_ARROW_INDEX=-1
   export ATUIN_CYCLE_MODE=0
   __atuin__up_arrow() {
      if [[ $ATUIN_CYCLE_MODE -eq 0 && -n "$READLINE_LINE" ]]; then
         # execute traditional atuin_history up arrow function, interactive backwards prefix search or whatever
         __atuin_history --shell-up-key-binding
         return
      fi

      export ATUIN_ARROW_INDEX=$((ATUIN_ARROW_INDEX + 1))
      export ATUIN_CYCLE_MODE=1

      HISTORY=$(atuin search --cmd-only --filter-mode host --limit 1 --offset $ATUIN_ARROW_INDEX)
      READLINE_LINE=${HISTORY}
      READLINE_POINT=${#READLINE_LINE}

      return
   }

   __atuin__down_arrow() {
      export ATUIN_ARROW_INDEX=$((ATUIN_ARROW_INDEX - 1))
      if [[ $ATUIN_ARROW_INDEX -lt 0 ]]; then
         __atuin__reset_arrow
         HISTORY=""
      else
         HISTORY=$(atuin search --cmd-only --filter-mode host --limit 1 --offset $ATUIN_ARROW_INDEX)
      fi
      READLINE_LINE=${HISTORY}
      READLINE_POINT=${#READLINE_LINE}

      return
   }

   __atuin__reset_arrow() {
      export ATUIN_ARROW_INDEX=-1
      export ATUIN_CYCLE_MODE=0
   }

   bind -x '"\e[A": __atuin__up_arrow'
   bind -x '"\eOA": __atuin__up_arrow'
   bind -x '"\e[B": __atuin__down_arrow'
   bind -x '"\eOB": __atuin__down_arrow'
   precmd_functions+=(__atuin__reset_arrow)
   return
fi

echo github.com/ellie/atuin not enabled

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
      __dedup $HISTFILE_SRC | __rm_histignore >|$HISTFILE_DST
      \mv "${HISTFILE_DST}" "${HISTFILE_SRC}"
      chmod go-r $HISTFILE_SRC
      history -c
      history -r
   fi
}
