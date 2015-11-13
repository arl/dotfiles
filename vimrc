" a lot of the cool stuff is coming from:
" https://github.com/romainl/dotvim/wiki/Mon-.vimrc-en-d%C3%A9tails

set nocompatible              " be iMproved, required
set modelines=1
set modeline
let mapleader=","             " set leader as ','

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
    Plugin 'jwhitley/vim-matchit.git'
    Plugin 'scrooloose/nerdcommenter.git'
    Plugin 'scrooloose/nerdtree.git'
    Plugin 'pangloss/vim-javascript'
    " disabled because i think it's a cause of some really slow startups of vim sometimes...
    "Plugin 'airblade/vim-gitgutter'
    Plugin 'fatih/vim-go'
    Plugin 'taglist.vim'
    Plugin 'fugitive.vim'
    Plugin 'majutsushi/tagbar'
    Plugin 'repeat.vim'
    Plugin 'surround.vim'
    Plugin 'kien/ctrlp.vim'
    Plugin 'vim-scripts/argtextobj.vim'
    Plugin 'cakebaker/scss-syntax.vim'

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

    " NERDTree
    map <F2> :NERDTreeToggle<CR>

    " taglist
    map <F9> :TlistToggle<CR>
    let Tlist_Use_Right_Window = 1
    let Tlist_Use_Singleclick = 1

    " tagbar
    nmap <F8> :TagbarToggle<CR>

    " CtrlP
    nnoremap <leader>f :CtrlP<CR>
    nnoremap <leader>F :CtrlPCurFile<CR>
    nnoremap <leader>b :CtrlPBuffer<CR>
    nnoremap <leader>m :CtrlPMixed<CR>
    nnoremap <leader>M :CtrlPMRUFiles<CR>
    nnoremap <leader>t :CtrlPTag<CR>
    nnoremap <leader>T :CtrlPBufTag<CR>
    " nnoremap <leader>N :CtrlP ~/Dropbox/nv/<CR>
    let g:ctrlp_extensions          = ['tag']
    let g:ctrlp_mruf_max            = 25
    let g:ctrlp_clear_cache_on_exit = 0
    let g:ctrlp_by_filename         = 1
    let g:ctrlp_open_new_file       = 'r'
    let g:ctrlp_open_multiple_files = '3hjr'
    let g:ctrlp_root_markers        = ['tags']

    " Surround
    " double quote on current word
    nmap " ysaw"

endif

filetype plugin indent on    " required


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cut/copy/paste like in m$
source $VIMRUNTIME/mswin.vim
behave mswin

"store lots of :cmdline history
set history=1000

" basic
set backspace=indent,eol,start
set hidden
set switchbuf=useopen,usetab
set tags=./tags;,tags;

" splitting
set splitbelow
set splitright

" search
set incsearch    " find the next match as we type the search
set hlsearch     " hilight searches by default
set ignorecase   " case ignored if search string is uppercase
set smartcase    " overrides ignorecase if string contains an uppercase letter
set gdefault     " 'g' is the default so s/../../

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Display Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set number       " line numbering
set paste        " can paste without problems

" for gvim only
set guifont=Consolas\ 10

" status bar
set statusline=%<\ %f\ %m%y%w%=\ L:\ \%l\/\%L\ C:\ \%c\ 
set laststatus=2               " display status bar permanently

set statusline=%<\             " begins with whitespace
set statusline+=%f             " filename
set statusline+=\              " whitespace
set statusline+=%m             " modified
set statusline+=%y             " filetype
set statusline+=%w             " preview
set statusline+=%=             " split
set statusline+=L:\ \%l\/\%L   " line number/total
set statusline+=\              " whitespace
set statusline+=C:\ \%c        " column number
set statusline+=\              " ends with whitespace


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs / Spaces
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" default tab values
""""""""""""""""""""
set tabstop=4    " size of a hard tabstop
set shiftwidth=4 " size of an "indent"

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4

" auto indent line after pressing Enter
set autoindent
set cindent
inoremap { {<CR>}<up><end><CR>

" per filetype
""""""""""""""""""""
au Filetype html setl sw=2 sts=2 ts=2 et sta
au Filetype css setl sw=2 sts=2 ts=2 et sta
au Filetype scss setl sw=2 sts=2 ts=2 et sta
au FileType python setl sw=4 sts=4 ts=4 et sta
au FileType javascript setl sw=2 sts=2 ts=2 et sta

" make vim understand that *.md is not modula!
autocmd BufNewFile,BufRead *.md set filetype=markdown

" do not show tabs and trailing spaces for go files
au FileType go set nolist


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" folding/unfolding with space
set foldnestmax=2
nnoremap <space> za
vnoremap <space> zf

" map :pop and :tag to CTRL-SHIFT-Left and CTRL-SHIFT-Right
map <C-Left> :pop<CR>
map <C-Right> :tag<CR>

" ALT + arrow to navigate between windows
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mouse Support in terminal
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mouse=a
set ttymouse=xterm2


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color Scheme
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" clearing uses the current background color
:set t_ut=

:colorscheme inkpot

