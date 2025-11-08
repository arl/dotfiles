# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# aliases for https://github.com/cespare/reflex
#

safewhich reflex || return

function reflexgo
{
  local cmdline="${*-go run .}"
  reflex -r '\.go$' -s -- sh -c "$cmdline"
}

