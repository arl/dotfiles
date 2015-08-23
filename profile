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
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# panty <<
# set PATH so it includes user's private bin dir if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$PATH:$HOME/bin"
fi
# set PATH so it includes user's private scripts dir if it exists
if [ -d "$HOME/scripts" ] ; then
    PATH="$PATH:$HOME/scripts"
fi

#export ANDROID_HOME=/home/panty/Documents/dev/adt-bundle-linux-x86_64-20131030/sdk
export ANDROID_HOME=/home/panty/Documents/dev/android-sdk-linux/
# set JAVA_HOME
#export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-amd64"

export NODE_PATH="/home/panty/node"


########################################################################################
# add android sdk to the path
#export PATH="$PATH:$ANDROID_HOME/tools/:$ANDROID_HOME/platform-tools/:$NODE_PATH/bin:$NODE_PATH/lib/node_modules"
export PATH="$PATH:$ANDROID_HOME/tools/:$ANDROID_HOME/platform-tools/:$NODE_PATH/bin:$NODE_PATH/lib/node_modules"

export GIT_EDITOR=vim

# to enable the soft-debugger in Monodevelop
export MONODEVELOP_SDB_TEST=yes

