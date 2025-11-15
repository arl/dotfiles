# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
# shellcheck shell=bash
#
# aliases for https://github.com/cespare/reflex
#

safewhich reflex || return

function reflexgo
{
  local cmdline="${*:-go run -race . | pp}"
  reflex -r '\.go$' -s -- bash -c "$cmdline"
}

