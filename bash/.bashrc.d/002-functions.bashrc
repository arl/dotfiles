# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Bash functions
#

# As which can have undesired side effects and can't always be used
# to know if a program exists, use safewhich, which is safe!
# 
# Credits goes to:
# http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
function safewhich() {
    command -v "$1" >/dev/null 2>&1
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
    tree -aC -I '.*.swp|.svn|.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Create a new directory and enter it
function mkd() {
    mkdir -p "$@" && cd "$_";
}

# Show useful filesystem disk space usage
function dfs() {
    df -Ph -x squashfs
}

# Convert base-16 integers to base-10
function hex2dec {
    local hex=$(echo "$@" | tr '[:lower:]' '[:upper:]')
    echo "ibase=16; ${hex}" | bc
}

# Convert base-10 integers to base-16
function dec2hex {
    echo "obase=16; $@" | bc
}