set guifont=Consolas\ 10
set guioptions-=m          " menu bar
set guioptions-=T          " toolbar
set guioptions-=r          " scrollbar
set lines=999 columns=999  " start gvim maximized

source $VIMRUNTIME/mswin.vim
behave mswin

:colorscheme slate
let g:colorschwitch_schemes = ['desert', 'darkblue', 'lucius', 'brookstream', 'torte', 'slate', 'gotham256', 'peachpuff', 'sourcerer', 'morning', 'pablo', 'koehler']
