# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# SSH agent and key setup
#

# Allow $USER to use keys. Only enter once and it will remain enabled till
# you delete it or reboot the server 
/usr/bin/keychain $HOME/.ssh/id_ed25519
source $HOME/.keychain/$HOSTNAME-sh
return

# Kept for reference but unused since switch to keychain
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

