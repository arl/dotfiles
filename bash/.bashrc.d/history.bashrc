# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# bash history
#

# Share history between different terminals
# The 3 next commands are taken from https://unix.stackexchange.com/questions/1288

# After each command, append to the history file and reread it
#PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -n; history -w; history -c; history -r"
PROMPT_COMMAND="history -n; history -w; history -c; history -r"

# ignoreboth ignores:
# - lines beggining with ' '
# - duplicated consecutive lines
# erasedups: erase duplicates lines
HISTCONTROL='ignoredups:erasedups'

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=4000