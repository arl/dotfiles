" a lot of the cool stuff is coming from:
" https://github.com/romainl/dotvim/wiki/Mon-.vimrc-en-d%C3%A9tails

set nocompatible              " be iMproved, required
set modelines=1
set modeline
let mapleader=","             " set leader as ','

if empty(glob("$HOME/.vim/bundle"))
    echo "Vundle plugin does not seems installed, run:"
    echo ""
    echo "\tgit submodule init && git submodule update"
    echo ""
else
    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""" Vundle Plugins """"""""""""""""""""
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    call vundle#begin()

    " let Vundle manage Vundle, required
    Plugin 'gmarik/Vundle.vim'
    Plugin 'jwhitley/vim-matchit.git'
    Plugin 'scrooloose/nerdcommenter.git'
    Plugin 'scrooloose/nerdtree.git'
    Plugin 'pangloss/vim-javascript'
    Plugin 'airblade/vim-gitgutter'
    Plugin 'fatih/vim-go'
    Plugin 'fugitive.vim'
    Plugin 'majutsushi/tagbar'
    Plugin 'repeat.vim'
    Plugin 'surround.vim'
    Plugin 'ctrlpvim/ctrlp.vim'
    Plugin 'vim-scripts/argtextobj.vim'
    Plugin 'cakebaker/scss-syntax.vim'
    Plugin 'itchyny/lightline.vim'
    Plugin 'Valloric/YouCompleteMe'
    Plugin 'will133/vim-dirdiff'
    Plugin 'scrooloose/syntastic'
    Plugin 'vim-scripts/bats.vim'
    Plugin 'tmhedberg/SimpylFold'

    " All of your Plugins must be added before the following line
    call vundle#end()            " required

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""" Plugin Configuration """"""""""""""""" 
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""

    " NERDTree
    map <F2> :NERDTreeToggle<CR>

    " tagbar
    nmap <F8> :TagbarToggle<CR>

    " for vim-go's GoTestFunc
    let g:go_jump_to_error = 0
    " CtrlP
    nnoremap <leader>f :CtrlP<CR>
    nnoremap <leader>F :CtrlPCurFile<CR>
    nnoremap <leader>b :CtrlPBuffer<CR>
    nnoremap <leader>m :CtrlPMixed<CR>
    nnoremap <leader>M :CtrlPMRUFiles<CR>
    nnoremap <leader>t :CtrlPTag<CR>
    nnoremap <leader>T :CtrlPBufTag<CR>
    let g:ctrlp_extensions          = ['tag']
    let g:ctrlp_mruf_max            = 25
    let g:ctrlp_use_caching = 0
    let g:ctrlp_by_filename         = 0
    let g:ctrlp_open_new_file       = 'r'
    let g:ctrlp_open_multiple_files = '3hjr'
    let g:ctrlp_root_markers        = ['tags']
    let g:ctrlp_user_command        = 'ag %s --files-with-matches --nocolor --smart-case -g ""'


    " dirdiff
    let g:DirDiffExcludes = ".git,.svn,*.pyc,*.exe,*.so,*.o,.*.swp"

    " lightline
    let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'fugitive': 'LightLineFugitive',
        \   'readonly': 'LightLineReadonly',
        \   'modified': 'LightLineModified',
        \   'filename': 'LightLineFilename'
        \ },
        \ 'separator': { 'left': '⮀', 'right': '⮂' },
        \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
        \ }

    function! LightLineModified()
      if &filetype == "help"
        return ""
      elseif &modified
        return "+"
      elseif &modifiable
        return ""
      else
        return ""
      endif
    endfunction

    function! LightLineReadonly()
      if &filetype == "help"
        return ""
      elseif &readonly
        return "⭤"
      else
        return ""
      endif
    endfunction

    function! LightLineFugitive()
      if exists("*fugitive#head")
        let _ = fugitive#head()
        return strlen(_) ? '⭠ '._ : ''
      endif
      return ''
    endfunction

    function! LightLineFilename()
      let fname = expand('%:t')
      return fname == 'ControlP' ? '' :
            \ fname == 'nerdtree' ? '' :
            \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
            \ ('' != fname ? fname : '[No Name]') .
            \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
    endfunction


    " syntastic
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0
    let g:syntastic_mode_map = {
        \ "mode": "passive",
        \ "active_filetypes": [""],
        \ "passive_filetypes": [""] }

    " SimpylFold
    autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
    autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<

endif

filetype plugin indent on    " required


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" map Ctrl-C/Ctrl-v to copy/paste
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <C-r><C-o>+

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
set diffopt=vertical " diffpatch splits vertically

" search
set incsearch    " find the next match as we type the search
set hlsearch     " hilight searches by default
set ignorecase   " case ignored if search string is uppercase
set smartcase    " overrides ignorecase if string contains an uppercase letter
set gdefault     " 'g' is the default so s/../../

" wildmenu
set wildmenu
set wildcharm=<C-z>
set wildignore=*.swp,*.bak
set wildignore+=*.pyc,*.class,*.sln,*.Master,*.csproj,*.csproj.user,*.cache,*.dll,*.pdb,*.min.*
set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
set wildignore+=tags
set wildignore+=*.tar.*
set wildignorecase
set wildmode=list:full

" line wrapping
set textwidth=80
nnoremap <leader>w gq<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set number       " line numbering
set paste        " can paste without problems
set laststatus=2 " display status bar permanently


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
au Filetype sh setl sw=2 sts=2 ts=2 et sta
au Filetype html setl sw=2 sts=2 ts=2 et sta
au Filetype css setl sw=2 sts=2 ts=2 et sta
au Filetype scss setl sw=2 sts=2 ts=2 et sta
au FileType python setl sw=4 sts=4 ts=4 et sta
au FileType javascript setl sw=2 sts=2 ts=2 et sta
au FileType dosini setl sw=2 sts=2 ts=2 et sta
au FileType gitconfig setl sw=2 sts=2 ts=2 et sta
au FileType go set nolist " no tabs/trailing spaces for fo

" make vim understand that *.md is not modula!
autocmd BufNewFile,BufRead *.md set filetype=markdown



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

" open ctag in tab split
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" open ctag in vertical split
map <leader><C-\> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

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

:colorscheme desert256

