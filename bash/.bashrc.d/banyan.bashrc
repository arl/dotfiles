# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# Add banyanproxy to the PATH
#


if [ -f /opt/Banyan/resources/bin/banyanproxy ]; then 
  export PATH="$PATH:/opt/Banyan/resources/bin"
fi
