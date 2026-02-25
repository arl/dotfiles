#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Bash functions
#
safewhich op || return 0

glt() {
    if ! op account get > /dev/null 2>&1; then
        echo "You are not logged into 1Password. Please run 'op signin' or unlock your app."
        return 1
    fi
    local selected_title
    if [ -n "$1" ]; then
      selected_title="Gitlab token - $1"
    else
      selected_title=$(op item list --tags "gitlab-token" --format=json \
        | jq -r '.[].title' \
        | fzf --prompt="Select GitLab Token: " --height=40% --layout=reverse \
      )
    fi
    if [ -z "$selected_title" ]; then
        return 0
    fi

    local token
    token=$(op item get "$selected_title" --fields password --reveal)

    if [ -z "$token" ]; then
        echo "❌ Failed to retrieve token for '$selected_title'. Make sure it is stored in the standard 'password' field."
        return 1
    fi

    export GITLAB_TOKEN="$token"
    export GITLAB_HOST="gitlab.comelz.com" 

    echo "Successfully configured environment for: $GITLAB_HOST"
    echo "GITLAB_TOKEN loaded with scope: $selected_title"
}
