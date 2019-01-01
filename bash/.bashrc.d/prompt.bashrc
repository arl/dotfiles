# vim: set ft=sh ts=2 sw=2 sts=2 et sta:
#
# prompt
#
PS1='[\u@\h \W]\$ '

function serious_prompt
{
    export PS1="\[\e[00;33m\]\u\[\e[0m\]\[\e[00;37m\]@\h:\[\e[0m\]\[\e[00;36m\][\w]:\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"
}

# credits to http://www.askapache.com/linux/bash-power-prompt.html
function rainbow_prompt
{
    export PS1='\n\e[1;30m[\j:\!\e[1;30m]\e[0;36m \T \d \e[1;30m[\e[1;$((31 + (++color % 7)))m\u\[\e[00;37m\]@\[\e[1;30m\]\H\e[1;30m:\e[0;37m`tty 2>/dev/null` \e[0;32m+${SHLVL}\e[1;30m] \e[1;36m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '
}

# set default prompt
rainbow_prompt