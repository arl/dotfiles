#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
safewhich direnv || return 0

eval "$(direnv hook bash)"
