# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# mdless alias for glow to read markdown files
# in the terminal
#
# go install github.com/charmbracelet/glow@latest

safewhich glow || return 0

mdless() {
  glow --width 0 --pager --style dark "${1:-.}"
}
