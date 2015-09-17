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

# set PATH so it includes user's private bin dir if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$PATH:$HOME/bin"
fi
# set PATH so it includes user's private scripts dir if it exists
if [ -d "$HOME/scripts" ] ; then
    PATH="$PATH:$HOME/scripts"
fi

############################################################
# machine specific values that can't be included in dotfiles
# because they are specific to a machine
#
# those will be treated is exported from '~/machine_specific':
# - ANDROID_HOME : android-sdk root directory
# - NODE_PATH    : NodeJS root directory
#
# envvars that aren't set won't be integrated in the PATH,
# nor processed elsewhere. This in the case the same
# 'dotfiles' git repo is used on machines with different
# usages
#
# note: do not add final '\' for folders

# look for machine specific folder
if [ -f $HOME/.machine_specific ]; then
    source $HOME/.machine_specific
fi

if [ -n "$ANDROID_HOME" ]; then
	export PATH="$PATH:$ANDROID_HOME/tools/:$ANDROID_HOME/platform-tools/"
fi
if [ -n "$NPM_PACKAGES" ]; then
	export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
	export PATH="$NPM_PACKAGES/bin:$PATH"

	# Unset manpath so we can inherit from /etc/manpath via the `manpath` command
	unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
	export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
fi

export GIT_EDITOR=vim

# from Linux Server Hacks book
function start_agent()
{
	if [ -f ~/.agent.env ]; then
	. ~/.agent.env > /dev/null

	if ! kill -0 $SSH_AGENT_PID > /dev/null 2>&1 ; then
		echo "Stale agent file found. Spawning new agent..."
		eval `ssh-agent | tee ~/.agent.env`
		# TODO: should read list of ssh_keys an array defined in machine_specific
		ssh-add ~/.ssh/id_rsa_gitlab ~/.ssh/id_rsa_github
	fi
		else
			echo "Starting ssh-agent..."
			eval `ssh-agent | tee ~/.agent.env`
			# TODO: should read list of ssh_keys an array defined in machine_specific
			ssh-add ~/.ssh/id_rsa_gitlab ~/.ssh/id_rsa_github
	fi
}
start_agent
