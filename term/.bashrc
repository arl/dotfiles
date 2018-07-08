#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

EDITOR=nvim

# Share history between different terminals
# The 3 next commands are taken from https://unix.stackexchange.com/questions/1288

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# ignoreboth ignores:
# - lines beggining with ' '
# - duplicateed consecutive lines
# erasedups: erase duplicates lines
HISTCONTROL='ignoreboth:erasedups'

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=4000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# If set, Bash replaces directory names with the results of word
# expansion when performing filename completion.
shopt -s direxpand

if [ -f ~/.bashrc.debian ]; then
    . ~/.bashrc.debian
fi

PS1='[\u@\h \W]\$ '

function serious_prompt
{
    export PS1="\[\e[00;33m\]\u\[\e[0m\]\[\e[00;37m\]@\h:\[\e[0m\]\[\e[00;36m\][\w]:\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"
}

# credits to http://www.askapache.com/linux/bash-power-prompt.html
function rainbow_prompt
{
    export PS1='\n\e[1;30m[\j:\!\e[1;30m]\e[0;36m \T \d \e[1;30m[\e[1;$((31 + (++color % 7)))m\u\[\e[00;37m\]@\[\e[1;30m\]\H\e[1;30m:\e[0;37m`tty 2>/dev/null` \e[0;32m+${SHLVL}\e[1;30m] \e[1;36m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '
}

export TERM=xterm-256color

# choose default prompt
rainbow_prompt

SSH_ENV=$HOME/.ssh/environment

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null

    # SSH_KEYS is read from $HOME/.machine_specific. A space separated list
    # of the private keys file is expected
    if [ -f "$HOME/.machine_specific" ]; then
        if [ -z ${SSH_KEYS+x} ]; then source "$HOME/.machine_specific"; fi
        for key in $SSH_KEYS; do /usr/bin/ssh-add "${key}" ; done
    fi
}

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_agent;
    }
else
    start_agent;
fi

# Stop vim freezing on accidental Ctrl-S, from
# http://unix.stackexchange.com/questions/12107
stty -ixon

# if fzf is installed, load key bindings and bash completion scripts
# see https://github.com/junegunn/fzf
if [ -f "$HOME/.fzf/bin/fzf" ]; then
    # fzf.bash is autogenerated during fzf installation
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    # fzf.functions is included in personal dotfiles repo
    [ -f ~/.fzf.functions ] && source ~/.fzf.functions
fi

RLWRAP_HOME="$HOME/.rlwrap"
if [ -f "$HOME/.machine_specific" ]; then
    source "$HOME/.machine_specific";
fi

# source .functions file
if [ -f "$HOME/.functions" ]; then
    source "$HOME/.functions"
fi

# read bash aliases from ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
