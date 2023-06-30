# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Bash aliases
#

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias pcregrep='pcregrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF1h'
alias lt='ls -alFt1h'
alias ltr='ls -alFtr1h'
alias la='ls -lA1h'
alias lc='ls -C'
alias lh='ls -lh'

# convert permissions to octal
alias lo="ls -l | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g' -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rwx/7/g' -e 's/---/0/g'"
alias cls='clear'

# less alias
alias less='less -FXR'   # -R = --RAW-CONTROL-CHARS'
                         # -F or --quit-if-one-screen
                         # -X or --no-init

# add lesc alias (pygmentize + less) if pygmentize is installed
if safewhich pygmentize
    then
    alias lesc='LESS="-R" LESSOPEN="|pygmentize -g %s" less -N'
    alias ccat='lesc '
fi

# tmux aliases
# to make tmux understands that we want utf8...
alias tmux='tmux -u'
alias tmat='tmux attach-session -t'
alias tmcs='tmux choose-session'
alias tmls='tmux list-sessions'
alias tmns='tmux new-session -s'

# alias sudo with 'sudo ' to have sudo'ed command aliased too
alias sudo='sudo '
alias suvi='sudo vi'

alias ag="ag -S -C 3 --pager 'less -FXR'"
# ag no context
alias agc0="ag -S --pager 'less -FXR'"
# alias *.go files only
alias ago='ag --file-search-regex '''.\*.go''''

# git aliases
alias glg='git lg '
alias gll='git lol '
alias gl='gll '
alias git_enableconfig="mv ~/.hiddengitconfig ~/.gitconfig"
alias git_disableconfig="mv ~/.gitconfig ~/.hiddengitconfig"

# svn aliases
alias svndt='svn diff '
alias svndiff='svn diff --internal-diff '

# rlwrap aliases (add readline where there isn't)
alias telnet="rlwrap -p'1;34' telnet "
alias "gopprof"="rlwrap -f $HOME/.rlwrap/pprof.completion -p'1;35' go tool pprof "

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# neovim alias
if safewhich nvim
    then
    alias vim=nvim
    alias vimdiff='nvim -d'
fi
alias vi=vim

if safewhich lazygit
    then
    alias zg='lazygit '
fi

# python virtualenv aliases
alias ve='python3 -m virtualenv ./.venv'
alias va='source ./.venv/bin/activate'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Timestamp aliases
alias ts='date +%s'
alias tsmilli='date +%s'000

if safewhich yaegi
    then
    alias yaegi="rlwrap -D 2 -R -s 1000 -pBlue yaegi"
fi
