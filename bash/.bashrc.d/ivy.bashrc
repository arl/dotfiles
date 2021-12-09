# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#

safewhich ivy || return 0

#rlwrap -S 'ivy> ' -pBLUE  ivy
alias ivy="rlwrap -S 'ivy> ' -p'1;35'  ivy"
