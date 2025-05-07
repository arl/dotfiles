#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# To install tfenv
# git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
#
[[ -d ~/.tfenv ]] || return

addToPATH "$HOME/.tfenv/bin"
