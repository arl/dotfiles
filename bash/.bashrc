#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for file in ~/.bashrc.d/*.bashrc;
do
 source "$file"
done
