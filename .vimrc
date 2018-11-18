set nocompatible              " be iMproved, required

" set vim-plug
call plug#begin()

" git wrapper
Plug 'tpope/vim-fugitive'
" vcs mark shower
Plug 'mhinz/vim-signify'
" status line
Plug 'bling/vim-airline'
" header/source file jump
Plug 'derekwyatt/vim-fswitch'
" folder/file browser
Plug 'scrooloose/nerdtree'
" enable nerdtree for tabs
Plug 'jistr/vim-nerdtree-tabs'
" auto close quotes, brackets
Plug 'Raimondi/delimitMate'
" comments shortcuts
Plug 'scrooloose/nerdcommenter'
" solarized colorscheme
Plug 'altercation/vim-colors-solarized'
" markdown
Plug 'plasticboy/vim-markdown'
" :Grep grep enhancement
Plug 'vim-scripts/grep.vim'
" block folder for python code
Plug 'tmhedberg/SimpylFold'
" Zen mode
Plug 'junegunn/goyo.vim'
" auto generate ctags
Plug 'ludovicchabant/vim-gutentags'
" show all functions in current file
Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
" completer
Plug 'Valloric/YouCompleteMe', { 'do': 'python3 ./install.py --clang-completer' }
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
" snippet
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

filetype plugin indent on

set laststatus=2 "always show statusline
set nu "show line numbers
set ruler "show ruler
set showcmd "show typed command
set smartindent
set autoindent
set backspace=indent,eol,start
set ignorecase "ignore letter case
set smartcase "with ignorecase, only ignore letter case when all letters are not upper
set incsearch
set hlsearch "highlight search result
set clipboard=unnamed "use system clipboard
let s:uname = system("uname -s")
if s:uname == "Linux\n"
    set clipboard=unnamedplus "use system clipboard
endif

set foldmethod=syntax
set foldcolumn=4 "fold column
match ErrorMsg '\s\+$'
set scrolloff=5

"color, font, etc.
set t_Co=256 "explicitly tell Vim that the terminal supports 256 colors
syntax enable
set background=dark
colorscheme ron
set cursorline
set colorcolumn=80,120
hi CursorLine term=bold cterm=bold ctermbg=black
hi SpellBad term=bold cterm=bold ctermbg=red "this is for warning words by youcompleteme
set guifont=Menlo_for_Powerline:h11
"highlight Folded ctermbg=darkgrey
"highlight FoldColumn ctermbg=darkgrey

"set up dictionary
set dictionary+=/usr/share/dict/words

"remember and open at the pos of the file when last time closed
autocmd BufReadPost * if line("'\"") && line("'\"") <= line("$") | exe "normal `\"" | endif

set completeopt=longest,menu
set tags=./.tags;,.tags
"build tags of my own cpp project with F11
map <F7> :call BuildTag()<CR>
function BuildTag()
	:YcmGenerateConfig
	:redraw!
endfunction

"set very magic for regular expression
:nnoremap / /\v
:nnoremap ? ?\v
:cnoremap s/ s/\v

"setup quickfix window size
autocmd FileType qf call AdjustWindowHeight(3, 20)
function! AdjustWindowHeight(minheight, maxheight)
	exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

"per language
set tabstop=8 expandtab shiftwidth=4 softtabstop=4
"autocmd FileType c setlocal tabstop=8 shiftwidth=8 softtabstop=8

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"plugin setting

"airline
let g:airline_powerline_fonts=1
let g:airline#extensions#whitespace#enabled=0

"nerdtree
let NERDTreeWinPos="right"
let NERDTreeWinSize=45
let NERDTreeAutoCenter=1
nnoremap <silent> <F10> :NERDTreeFind<CR>

"nerdtree-tabs
let g:nerdtree_tabs_open_on_console_startup=1
let g:nerdtree_tabs_focus_on_files=1
let g:nerdtree_tabs_open_on_gui_startup=1
nnoremap <silent> <F9> :NERDTreeTabsToggle<CR>

"UltiSnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

"YCM
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_global_ycm_extra_conf = "~/.ycm_extra_conf.py"
let g:ycm_confirm_extra_conf = 0
let g:ycm_python_binary_path = 'python'

"grep.vim
let Grep_Default_Options = '-iIRnE --color=auto --exclude-dir={.bzr,.cvs,.git,.hg,.svn} --exclude={.tags,cscope.out}'
let Grep_Default_Filelist = '.'

"goyo.vim
let g:goyo_width = 120
let g:goyo_height = 100

"vim-signify
nnoremap <silent> <F6> :SignifyDiff<CR>

"vim-gutentags
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
let g:gutentags_ctags_tagfile = '.tags'
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
if !isdirectory(s:vim_tags)
    silent! call mkdir(s:vim_tags, 'p')
endif

"LeaderF
nnoremap <silent> <F8> :LeaderfFile<CR>
noremap <C-P> :LeaderfFunction!<CR>
