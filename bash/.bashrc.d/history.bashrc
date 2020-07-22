# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# bash history
#

# Share history between different terminals
# The 3 next commands are taken from https://unix.stackexchange.com/questions/1288

# After each command, append to the history file and reread it
PROMPT_COMMAND="history -a; history -c; history -r;"

HISTCONTROL='ignoredups:erasedups'

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# See HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=4000
