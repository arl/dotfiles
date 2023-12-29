#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Bash functions
#

# As which can have undesired side effects and can't always be used
# to know if a program exists, use safewhich, which is safe!
#
# Credits goes to:
# http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
safewhich() {
    command -v "$1" >/dev/null 2>&1
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
    tree -aC -I '.*.swp|.svn|.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Create a new directory and enter it
mkd() {
    mkdir -p "$@" && cd "$_"
}

# Show useful filesystem disk space usage
dfs() {
    df -Ph -x squashfs
}

# Convert base-16 integers to base-10
hex2dec() {
    local hex=$(echo "$@" | tr '[:lower:]' '[:upper:]')
    echo "ibase=16; ${hex}" | bc
}

# Convert base-10 integers to base-16
dec2hex() {
    echo "obase=16; $@" | bc
}

# Convert base-16 integers to binary
hex2bin() {
    local hex=$(echo "$@" | tr '[:lower:]' '[:upper:]')
    echo "ibase=16; obase=2; ${hex}" | bc
}

# Convert base-2 integers to base-16
bin2hex() {
    printf 'obase=16; ibase=2; %s\n' "$1" | bc
}

# Convert base-10 integers to binary
dec2bin() {
    echo "obase=2; $@" | bc
}

# Convert base-16 integers to base-10
bin2dec() {
    echo "ibase=2; $@" | bc
}

# Copy last executed terminal command into the clipboard
copycmd() {
    history 2 | head -n 1 | cut -d " " -f 4- | xclip -sel cli
}

urldecode() {
    : "${*//+/ }"
    echo -e "${_//%/\\x}"
}

# Copy the absolute path to the argument in the clipboard. Without argument,
# copy the working directory.
clipath() {
    safewhich xclip && readlink -e "${1:-.}" | tr -d '\r\n' | xclip -sel cli
}

# Change directory and list its content at the same time.
# from https://opensource.com/article/19/7/bash-aliases
function cl() {
    DIR="$*"
    # if no DIR given, go home
    if [ $# -lt 1 ]; then
        DIR=$HOME
    fi
    builtin cd "${DIR}" &&
        ls -alF1h --color=auto
}
