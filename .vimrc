set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
if has('win32')
	set rtp+=~/vimfiles/bundle/vundle/
	let path='~/vimfiles/bundle'
	call vundle#rc(path)
else
	set rtp+=~/.vim/bundle/vundle/
	call vundle#rc()
endif
" alternatively, pass a path where Vundle should install plugins
"let path = '~/some/path/here'
"call vundle#rc(path)

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'

" The following are examples of different formats supported.
" Keep Plugin commands between here and filetype plugin indent on.
" scripts on GitHub repos
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'
Plugin 'chazy/cscope_maps'
Plugin 'derekwyatt/vim-fswitch'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'majutsushi/tagbar'
Plugin 'Raimondi/delimitMate'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'altercation/vim-colors-solarized'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'vim-scripts/grep.vim'
Plugin 'chrisbra/vim-diff-enhanced'
Plugin 'tmhedberg/SimpylFold'
Plugin 'junegunn/goyo.vim'
if !has('win32')
	if !has('win32unix')
		Plugin 'Valloric/YouCompleteMe'
		Plugin 'rdnetto/YCM-Generator'
	endif
	Plugin 'SirVer/ultisnips'
	Plugin 'honza/vim-snippets'
endif
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" scripts from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
"Plugin 'FuzzyFinder'
" scripts not on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" ...

filetype plugin indent on     " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Plugin commands are not allowed.
" Put your stuff after this line

if has('win32')
	source $VIMRUNTIME/vimrc_example.vim
	source $VIMRUNTIME/mswin.vim
	set nobackup
	behave mswin
	set encoding=utf-8
	set guifont=Menlo_for_Powerline:h12
	au GUIEnter * simalt ~x

	set diffexpr=MyDiff()
	function MyDiff()
	  let opt = '-a --binary '
	  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
	  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
	  let arg1 = v:fname_in
	  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
	  let arg2 = v:fname_new
	  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
	  let arg3 = v:fname_out
	  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
	  let eq = ''
	  if $VIMRUNTIME =~ ' '
	    if &sh =~ '\<cmd'
	      let cmd = '""' . $VIMRUNTIME . '\diff"'
	      let eq = '"'
	    else
	      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
	    endif
	  else
	    let cmd = $VIMRUNTIME . '\diff'
	  endif
	  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
	endfunction
endif

set laststatus=2 "always show statusline
set nu "show line numbers
set ruler "show ruler
set showcmd "show typed command
set t_Co=256 "explicitly tell Vim that the terminal supports 256 colors
set smartindent
set autoindent
set backspace=indent,eol,start
set ignorecase "ignore letter case
set smartcase "with ignorecase, only ignore letter case when all letters are not upper
set incsearch
set hlsearch "highlight search result
if has('unix')
	let s:uname = system("uname -s")
	if s:uname == "Linux"
		set clipboard=unnamedplus "use system clipboard
	endif
else
	set clipboard=unnamed "use system clipboard
endif
set foldmethod=syntax
set foldcolumn=4 "fold column
match ErrorMsg '\s\+$'
set scrolloff=5

"color, font, etc.
syntax enable
set background=dark
colorscheme solarized
set cursorline
set colorcolumn=80
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
"build tags of my own cpp project with Ctrl-F11
map <C-F11> :!ctags -R --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>

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
autocmd FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4
autocmd FileType perl setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4
autocmd FileType ruby setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4
autocmd FileType java setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4
"autocmd FileType cpp setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4
autocmd BufRead,BufNewFile *.py let python_highlight_all=1
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1


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
"let g:nerdtree_tabs_open_on_console_startup=1
let g:nerdtree_tabs_focus_on_files=1
let g:nerdtree_tabs_open_on_gui_startup = 0
nnoremap <silent> <F9> :NERDTreeTabsToggle<CR>

"tagbar
let g:tagbar_left=1
let g:tagbar_sort=0
let g:tagbar_autoshowtag=1
set updatetime=1000
"let g:tagbar_width=28
autocmd VimEnter * nested :call tagbar#autoopen(1)
nnoremap <silent> <F8> :TagbarToggle<CR>

"UltiSnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

"YCM
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_global_ycm_extra_conf = "~/.ycm_extra_conf.py"
let g:ycm_confirm_extra_conf = 0

"grep.vim
let Grep_Default_Options = '-iIRnE --color=auto --exclude-dir={.bzr,.cvs,.git,.hg,.svn} --exclude={tags,cscope.out}'
let Grep_Default_Filelist = '.'

"goyo.vim
let g:goyo_width = 120
let g:goyo_height = 100
nnoremap <silent> <F7> :Goyo<CR>
