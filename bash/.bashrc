#
# ~/.bashrc
#

# Uncomment this if for whatever reasons bash exits before giving us a prompt
# set -x

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for file in ~/.bashrc.d/*.bashrc;
do
 source "$file"
done
