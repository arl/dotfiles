# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes user's private scripts dir if it exists
if [ -d "$HOME/dev/scripts" ]; then
    PATH="$PATH:$HOME/dev/scripts"
fi

############################################################
# machine specific values that can't be included in dotfiles
# because they are specific to a machine
#
# Those will be treated if exported from '~/machine_specific':
# - ANDROID_HOME : android-sdk root directory
# - NODE_PATH    : NodeJS root directory
#
# Env vars that aren't set won't be integrated in the PATH,
# nor processed elsewhere. This in the case the same
# 'dotfiles' git repo is used on machines with different
# usages
#
# note: do not add final '\' for folders

# look for machine specific config file
if [ -f "$HOME/.machine_specific" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.machine_specific"
fi

# If set and if it exists, add LOCAL GO /bin directory to the path
if [ -d /usr/local/go/bin ]; then
    if [ -d "/usr/local/go/bin" ]; then
        export PATH="/usr/local/go/bin:$PATH"
    fi
fi

# If set and if it exists, use GOPATH and add $GOPATH/bin to the path
if [ -n "$GOPATH" ]; then
    if [ -d "$GOPATH" ]; then
        export PATH="$GOPATH:$PATH"
    fi
fi

export GIT_EDITOR=vim
export EDITOR=vim

# shellcheck source=/dev/null
