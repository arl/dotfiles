" a lot of the cool stuff is coming from:
" https://github.com/romainl/dotvim/wiki/Mon-.vimrc-en-d%C3%A9tails

syntax on
set nocompatible              " be iMproved, required
set modelines=1
set modeline
set exrc
let mapleader=","             " set leader as ','

call plug#begin()

    " sort with :14,51sort i
    Plug 'airblade/vim-gitgutter'
    Plug 'arl/colorschwitch'
    Plug 'brooth/far.vim'
    Plug 'cocopon/lightline-hybrid.vim'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'easymotion/vim-easymotion'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'elzr/vim-json'
    Plug 'govim/govim'
    Plug 'iCyMind/NeoSolarized'
    Plug 'itchyny/lightline.vim'
    Plug 'jez/vim-superman'
    Plug 'jiangmiao/auto-pairs'
    Plug 'junegunn/goyo.vim'
    Plug 'junegunn/gv.vim'
    Plug 'keith/travis.vim'
    Plug 'majutsushi/tagbar'
    Plug 'Matt-Deacalion/vim-systemd-syntax'
    Plug 'maximbaz/lightline-ale'
    Plug 'mileszs/ack.vim'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'roxma/vim-tmux-clipboard'
    Plug 'rust-lang/rust.vim'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'scrooloose/syntastic'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-rhubarb'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    Plug 'unblevable/quick-scope'
    Plug 'vim-scripts/argtextobj.vim'
    Plug 'vim-scripts/bats.vim'
    Plug 'will133/vim-dirdiff'
    Plug 'yami-beta/asyncomplete-omni.vim'
    if has('nvim')
        Plug 'morhetz/gruvbox'
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        Plug 'zchee/deoplete-clang'
        let g:deoplete#enable_at_startup = 1
        let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-3.8/lib/libclang.so.1'
        let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'
    endif

call plug#end()

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""" Plugin Configuration """"""""""""""""" 
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""

    " NERDTree
    map <F2> :NERDTreeToggle<CR>

    " tagbar
    nmap <F8> :TagbarToggle<CR>

    " asyncomplete and go
    function! Omni()
        call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
                        \ 'name': 'omni',
                        \ 'whitelist': ['go'],
                        \ 'completor': function('asyncomplete#sources#omni#completor')
                        \  }))
    endfunction
    au VimEnter * :call Omni()

    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

    " To automatically show doc in popus when hovering
    set completeopt=menuone,noinsert,noselect,popup
    let g:asyncomplete_auto_completeopt = 0

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
        \ 'colorscheme': 'gruvbox',
        \ 'active': {
        \   'left':  [
        \     ['mode', 'paste'],
        \     ['fugitive', 'filename'],
        \   ],
        \   'right': [
        \     ['linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok']
        \     ],
        \ },
        \ 'component_function': {
        \   'fugitive': 'LightLineFugitive',
        \   'readonly': 'LightLineReadonly',
        \   'modified': 'LightLineModified',
        \   'filename': 'LightLineFilename'
        \ },
        \ 'component_expand': {
        \   'linter_checking': 'lightline#ale#checking',
        \   'linter_warnings': 'lightline#ale#warnings',
        \   'linter_errors': 'lightline#ale#errors',
        \   'linter_ok': 'lightline#ale#ok',
        \ },
        \ 'component_type': {
        \   'linter_checking': 'left',
        \   'linter_warnings': 'warning',
        \   'linter_errors': 'error',
        \   'linter_ok': 'left',
        \ },
        \ 'separator': { 'left': '⮀', 'right': '⮂' },
        \ 'subseparator': { 'left': '⮀', 'right': '⮂' }
        \ }

    let g:lightline#ale#indicator_checking = "\uf110"
    let g:lightline#ale#indicator_warnings = "\uf071"
    let g:lightline#ale#indicator_errors = "\uf05e"
    let g:lightline#ale#indicator_ok = "\uf00c"

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

    " quick-scope
    " " Trigger a highlight in the appropriate direction when pressing these keys:
    let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

    " auto-pairs
    " NOTE: ALT-P toggles the plugin

    " editorconfig-vim
    " to ensure that this plugin works well with Tim Pope's fugitive, use the
    " following patterns array:
    let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
    let g:EditorConfig_exec_path = '/usr/bin/editorconfig'

    " vim-grepper
    runtime plugin/grepper.vim
    nnoremap <leader>g :Grepper<cr>
    let g:grepper = { 'next_tool': '<leader>g' }
    nmap gs  <plug>(GrepperOperator)
    xmap gs  <plug>(GrepperOperator)

    " ack.vim
    if executable('ag')
      "let g:ackprg = 'ag\ --vimgrep\ -S'
      let g:ackprg = 'ag'
      let g:ack_default_options = " -s -H --nocolor --nogroup --column --smart-case --follow"
      " by default, do not jump to first result
      cnoreabbrev Ack Ack!
    endif

    filetype plugin indent on    " required

    " ale

    " rust
    let g:rustfmt_autosave = 1

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
set tags=./.git/tags;./tags;,tags;

" splitting
set splitbelow
set splitright
set diffopt=vertical " diffpatch splits vertically

" search
set incsearch    " find the next match as we type the search
set hlsearch     " highlight searches by default
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

" H to show help in vertical split
command! -nargs=1 H call s:ShowHelp(<f-args>)


" annoying temporary files
set backupdir=/tmp//,.
set directory=/tmp//,.
if v:version >= 703
  set undodir=/tmp//,.
endif

" disable automatic braces
let g:autoclose_on = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set number       " line numbering
set nopaste      " paste is obsolete
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

" handle ivy files as R
autocmd BufNewFile,BufRead *.ivy set filetype=r


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
if !has('nvim')
    set ttymouse=xterm2
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color Scheme
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" clearing uses the current background color
:set t_ut=

" default colorscheme
:colorscheme desert256
