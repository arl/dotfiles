set nocompatible              " be iMproved, required
set modelines=1
set modeline 

if empty(glob("$HOME/.vim/bundle"))
	echo "Vundle plugin does not seems installed, to install it:"
	echo ""
	echo "\tgit clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
	echo "then from the shell:"
	echo "\tvim +PluginInstall +qall"
else
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
	Plugin 'http://github.com/scrooloose/nerdcommenter.git'
	Plugin 'http://github.com/scrooloose/nerdtree.git'
	Bundle 'pangloss/vim-javascript'
	Plugin 'airblade/vim-gitgutter'
	"Plugin 'http://github.com/davidhalter/jedi-vim.git'

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
endif

filetype plugin indent on    " required


" folding/unfolding with space
set foldnestmax=2
nnoremap <space> za
vnoremap <space> zf

" default tab values
" size of a hard tabstop
set tabstop=4

" size of an "indent"
set shiftwidth=4

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4

" line numbering
set number
" paste mode
set paste


" map Ctrl-C to copy to system clipboard
map <C-c> "+y<CR>

" map :pop and :tag to CTRL-SHIFT-Left and CTRL-SHIFT-Right
if ! has("gui_running")
  noremap  <ESC>[1;6D <C-Left>
  inoremap <ESC>[1;6D <C-Left>
  noremap  <ESC>[1;6C <C-Right>
  inoremap <ESC>[1;6C <C-Right>
endif

map <C-S-Left> :pop<CR>
map <C-S-Right> :tag<CR>

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif



" per filetype
au filetype html setl sw=2 sts=2 ts=2 et sta
au FileType python setl sw=4 sts=4 ts=4 et sta
au FileType javascript setl sw=2 sts=2 ts=2 et sta


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mouse Support, for normal mode only
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" useful for scrolling
set mouse=n

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color Scheme
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:colorscheme sourcerer

