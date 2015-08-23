# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    # aurelien: maybe 'color=auto' would be better...
    alias ls='ls --color=always'
    alias grep='grep --color=always'
    alias pcregrep='pcregrep --color=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
fi

# some more ls aliases
alias ll='ls -alF1'
alias lt='ls -alFt1'
alias ltr='ls -alFtr1'
alias la='ls -lA1'
alias l='ls -CF1'
alias cls='clear'
alias less='less --RAW-CONTROL-CHARS'

# git aliases
alias gitst='git status'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# alias rm with trash-put to avoid accidents! and inform the user about it
alias rm='trash-put'
alert 'rm command will move delete files to trash for safety'

# alias sudo with 'sudo ' to have sudo'ed command aliased too
alias sudo='sudo '

