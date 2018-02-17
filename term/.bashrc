# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

EDITOR=vi

# Share history between different terminals
# The 3 next commands are taken from https://unix.stackexchange.com/questions/1288

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups:erasedups

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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# source .functions file
if [ -f "$HOME/.functions" ]; then
    source "$HOME/.functions"
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

PS1="\$\[\e[0m\] "
function serious_prompt
{
    export PS1="\[\e[00;33m\]\u\[\e[0m\]\[\e[00;37m\]@\h:\[\e[0m\]\[\e[00;36m\][\w]:\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"
}

# credits to http://www.askapache.com/linux/bash-power-prompt.html
function rainbow_prompt
{
    export PS1='\n\e[1;30m[\j:\!\e[1;30m]\e[0;36m \T \d \e[1;30m[\e[1;$((31 + (++color % 7)))m\u\[\e[00;37m\]@\[\e[1;30m\]\H\e[1;30m:\e[0;37m`tty 2>/dev/null` \e[0;32m+${SHLVL}\e[1;30m] \e[1;36m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '
}

export TERM=screen-256color

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

