# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Add vman to the PATH and alias make it a man alias
#
# https://github.com/jez/vim-superman


# If vman is installed add VMAN_BIN to the PATH
VMAN_BIN=$HOME/.vim/plugged/vim-superman/bin
if [ -f "${VMAN_BIN}/vman" ];
then
  export PATH=$PATH:$VMAN_BIN
  alias man=vman
fi
