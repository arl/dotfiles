set nocompatible              " be iMproved, required
set modelines=1
set modeline 

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim


""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""" Vundle Plugins """"""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'http://github.com/othree/javascript-libraries-syntax.vim.git'
Plugin 'http://github.com/scrooloose/nerdcommenter.git'
Plugin 'http://github.com/scrooloose/nerdtree.git'
Bundle "pangloss/vim-javascript"
Bundle 'wookiehangover/jshint.vim'
Plugin 'airblade/vim-gitgutter'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""" Plugin Configuration """"""""""""""""" 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F2> :NERDTreeToggle<CR>

filetype plugin indent on    " required


" default tab values
" size of a hard tabstop
set tabstop=4

" size of an "indent"
set shiftwidth=4

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4


set nu
set paste

" per filetype
au filetype html setl sw=2 sts=2 ts=2 et sta
"au FileType python setl sw=4 sts=4 ts=4 et sta
au FileType javascript setl sw=2 sts=2 ts=2 et sta


:colorscheme elflord
