# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# AWS-cli bash autocomplete
#

safewhich aws || return 0
complete -C '/usr/local/bin/aws_completer' aws
