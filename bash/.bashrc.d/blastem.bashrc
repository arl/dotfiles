#!/bin/bash
# vim: set ft=sh ts=2 sw=2 sts=2 et sta:

# Add BlastEm installation dir to $PATH if present.
[[ -d ~/.local/blastem64-0.6.2 ]] && addToPATH "$HOME/.local/blastem64-0.6.2"