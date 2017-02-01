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
    Plugin 'airblade/vim-gitgutter'
    Plugin 'fatih/vim-go'
    Plugin 'fugitive.vim'
    Plugin 'majutsushi/tagbar'
    Plugin 'repeat.vim'
    Plugin 'surround.vim'
    Plugin 'ctrlpvim/ctrlp.vim'
    Plugin 'vim-scripts/argtextobj.vim'
    Plugin 'itchyny/lightline.vim'
    Plugin 'Shougo/neocomplete.vim'
    Plugin 'Shougo/vimproc.vim'
    Plugin 'will133/vim-dirdiff'
    Plugin 'scrooloose/syntastic'
    Plugin 'vim-scripts/bats.vim'
    Plugin 'tikhomirov/vim-glsl'
    Plugin 'elzr/vim-json'
    Plugin 'whatyouhide/vim-gotham'
    Plugin 'aurelien-rainone/colorschwitch'

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
    let g:go_fmt_command = "goimports"

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
    let g:ctrlp_lazy_update         = 1
    let g:ctrlp_use_caching         = 1
    let g:ctrlp_by_filename         = 0
    let g:ctrlp_open_new_file       = 'r'
    let g:ctrlp_open_multiple_files = '3hjr'
    let g:ctrlp_root_markers        = ['tags']
    let g:ctrlp_user_command        = 'ag %s --files-with-matches --nocolor --smart-case -g ""'


    " dirdiff
    let g:DirDiffExcludes = ".git,.svn,*.pyc,*.exe,*.so,*.o,.*.swp"

    " lightline
    let g:lightline = {
        \ 'colorscheme': 'gotham256',
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


    " Syntastic
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    " disable automatic checks
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0
    let g:syntastic_mode_map = {
        \ "mode": "passive",
        \ "active_filetypes": [""],
        \ "passive_filetypes": [""] }
    " instead press F5 for manual check
    nnoremap <silent> <F5> :SyntasticCheck<CR>

    " flake8: quiet specific messages
    " E501 : line too long
    let g:syntastic_python_flake8_args='--ignore=E501'

    " neocomplete.vim
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
      return pumvisible() ? "\<C-y>" : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
    endif

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

" help
function! s:ShowHelp(tag) abort
  if winheight('%') < winwidth('%')
    execute 'vertical help '.a:tag
  else
    execute 'help '.a:tag
  endif
endfunction

command! -nargs=1 H call s:ShowHelp(<f-args>)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set number       " line numbering
set paste        " can paste without problems
set laststatus=2 " display status bar permanently
syntax enable


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
au Filetype json setl sw=2 sts=2 ts=2 et sta
au Filetype html setl sw=2 sts=2 ts=2 et sta
au Filetype css setl sw=2 sts=2 ts=2 et sta
au Filetype scss setl sw=2 sts=2 ts=2 et sta
au FileType python setl list sw=4 sts=4 ts=4 et sta
au FileType javascript setl sw=2 sts=2 ts=2 et sta
au FileType dosini setl sw=2 sts=2 ts=2 et sta
au FileType gitconfig setl sw=2 sts=2 ts=2 et sta
au FileType cpp setl sw=4 sts=4 ts=4 et sta
au FileType glsl setl sw=4 sts=4 ts=4 et sta
au FileType go set nolist " no tabs/trailing spaces for go
au FileType c set nolist
au FileType haskell setl sw=2 sts=2 ts=2 et sta

" make vim understand that *.md is not modula!
autocmd BufNewFile,BufRead *.md set filetype=markdown

" treat .vert and .frag as glsl
autocmd BufNewFile,BufRead *.vert set filetype=glsl
autocmd BufNewFile,BufRead *.frag set filetype=glsl


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" folding/unfolding with space
set foldnestmax=2
nnoremap <space> za
vnoremap <space> zf

" map :pop and :tag to CTRL-Left/Right
map <C-Left> :pop<CR>
map <C-Right> :tag<CR>

" map :tabprevious and :tabnext to leader-CTRL-Left/Right
nmap <silent> <leader><C-Left> :tabprevious<CR>
nmap <silent> <leader><C-Right> :tabnext<CR>

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

" open ctag in vertical split
map <C-\> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
" open ctag in tab split
map <leader><C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" F4 to switch between C++ header/source file
nnoremap <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>

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

" default colorscheme
:colorscheme sourcerer
let g:colorschwitch_schemes = ['delek', 'slate', 'gotham256', 'sourcerer', 'morning']

function! DoMirror ()
  call vimproc#system_bg('python mirror.py --sync')
endfunction

nmap <F3> :call DoMirror()<CR>
