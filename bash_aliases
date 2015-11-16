# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'
    alias grep='grep --color=auto'
    alias pcregrep='pcregrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF1'
alias lt='ls -alFt1'
alias ltr='ls -alFtr1'
alias la='ls -lA1'
alias l='ls -CF1'
alias cls='clear'

alias less='less --RAW-CONTROL-CHARS'

# tmux aliases
# to make tmux understands that we want utf8...
alias tmux='tmux -u'
alias tmat='tmux attach-session -t'
alias tmcs='tmux choose-session'
alias tmls='tmux list-sessions'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# alias sudo with 'sudo ' to have sudo'ed command aliased too
alias sudo='sudo '

alias ag="ag -C 3 --pager 'less -R'"
