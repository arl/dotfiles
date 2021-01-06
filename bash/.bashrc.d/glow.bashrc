# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# mdless alias for glow to read markdown files
# in the terminal
#
# go get -u github.com/charmbracelet/glow

if safewhich glow
  then
  mdless() {
    # Provide . to glow if no arguments, so that glow opens
    # README.md if it finds one in the current directory.
    glow -p -s dark ${1:-.}
  }
fi
