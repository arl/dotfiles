#
# ~/.bashrc
#

# Uncomment this if for whatever reasons bash exits before giving us a prompt.
# set -x

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

for file in ~/.bashrc.d/*.bashrc; do
  # shellcheck source=/dev/null
  source "$file"
done
