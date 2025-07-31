#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# https://encore.dev/docs
#
[[ -d ~/.encore ]] || return

export ENCORE_INSTALL="/home/aurelien/.encore"
addToPATH "$ENCORE_INSTALL/bin"
