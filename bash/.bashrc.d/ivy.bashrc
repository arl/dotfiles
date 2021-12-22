# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#

safewhich ivy || return 0
alias ivy="rlwrap --file \$HOME/.ivy.completion --substitute-prompt='ivy> ' --prompt-colour='1;35' ivy"
