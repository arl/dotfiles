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

for file in "$HOME/.bashrc.d"/*.bashrc; do
  # shellcheck source=/dev/null
  source "$file"
done

if [ -d "$HOME/.bashrc_private.d" ]; then
    for file in "$HOME/.bashrc_private.d"/*.bashrc; do
        # shellcheck source=/dev/null
        source "$file"
    done
fi
