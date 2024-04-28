# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# plan9port, for acme
#
PLAN9="/usr/local/plan9"

# Check if /usr/local/plan9 exists and is a directory
[ -d  $PLAN9 ] || return

export PLAN9
PATH=$PATH:$PLAN9/bin

alias acme="acme -m /mnt/acme -f /mnt/font/Consolas/12a/font"
