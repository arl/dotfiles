safewhich tmux || return 0

# tmux aliases
# to make tmux understands that we want utf8...
alias tmux='tmux -u'
alias tmcs='tmux choose-session'
alias tmls='tmux list-sessions'

tmns() {
  local name
  name=$(basename -- "$PWD")
  if [[ $# -gt 0 ]]; then
    name=$1
    shift
  fi
  command tmux -u new-session -A -s "$name" "$@"
}
