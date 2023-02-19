" set vim-plug
call plug#begin()

" git mark shower
Plug 'airblade/vim-gitgutter'
" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" auto close quotes, brackets
Plug 'windwp/nvim-autopairs'
" comments shortcuts
Plug 'preservim/nerdcommenter'
" gruvbox colorscheme
Plug 'morhetz/gruvbox'
" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
" fuzzy finder and many things else
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" completer, snippets
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
" Folder navigation
Plug 'preservim/nerdtree'
" session
Plug 'mhinz/vim-startify'
" icons
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

call plug#end()

filetype plugin indent on

set laststatus=2
set number
set ruler
set showcmd
set smartindent
set autoindent
set backspace=indent,eol,start
set ignorecase
set smartcase
set incsearch
set hlsearch
set clipboard+=unnamedplus
set splitbelow
set splitright
set scrolloff=5
set jumpoptions=stack
set mouse=

"terminal
tnoremap <Esc> <C-\><C-n>
tnoremap <C-w> <C-\><C-n><C-w>
nnoremap T :split \| terminal<CR>i

"ui, color, font, etc.
syntax enable
set termguicolors
set background=dark
colorscheme gruvbox
set cursorline
set colorcolumn=80,120
match ErrorMsg '\s\+$'

"remember and open at the pos of the file when last time closed
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif

set completeopt=menuone,noselect

"set very magic for regular expression
nnoremap / /\v
vnoremap / y/<C-r>"<CR>
nnoremap ? ?\v
vnoremap ? y?<C-r>"<CR>
cnoremap s/ s/\v

let mapleader = " "

"setup quickfix window size
augroup qfwin
    autocmd!
    autocmd FileType qf call AdjustWindowHeight(3, 20)
augroup END
function! AdjustWindowHeight(minheight, maxheight)
    execute max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

"per language
set tabstop=8 expandtab shiftwidth=4 softtabstop=4
"autocmd FileType c setlocal tabstop=8 noexpandtab shiftwidth=8 softtabstop=8
"autocmd FileType cpp setlocal tabstop=8 noexpandtab shiftwidth=8 softtabstop=8
autocmd FileType dts setlocal foldmethod=indent foldignore=

"plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16_gruvbox_dark_hard'
let g:airline#extensions#tabline#enabled = 1

"UltiSnips
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsExpandTrigger = "<c-j>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"

"vim-gitgutter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>1 :GitGutterDiffOrig<CR>

"nerdtree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>F :NERDTreeToggle<CR>

"startify
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:startify_session_persistence = 1

"nvim-cmp
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
local cmp = require'cmp'

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({'/', '?'}, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  -- mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
EOF

"nvim-lspconfig
"mason
"mason-lspconfig
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF

local servers = {
  "clangd",
  "neocmake",
  "rust_analyzer",
}

require("mason").setup()
require("mason-lspconfig").setup { ensure_installed = servers, }

local lspconfig = require("lspconfig")

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>n', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>p', vim.lsp.buf.format, opts)

  if client.server_capabilities.document_highlight then
    vim.cmd [[
      hi LspReferenceRead cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828
      hi LspReferenceText cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828
      hi LspReferenceWrite cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end
end

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end
EOF
set updatetime=2000

"nvim-autopairs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
require('nvim-autopairs').setup{}
EOF

"nvim-telescope
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
local actions = require("telescope.actions")
require("telescope").setup{
  defaults = {
    dynamic_preview_title = true,
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  }
}

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>f', function() builtin.find_files({ default_text = vim.fn.expand('%:~:.:h') }) end, {})
vim.keymap.set('n', '<leader>w', function() builtin.grep_string({ word_match = "-w" }) end, {})
vim.keymap.set('n', '<leader>s', builtin.grep_string, {})
vim.keymap.set('n', '<leader>S', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>o', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>m', function() builtin.main_pages({ sections = { "ALL" } }) end, {})
vim.keymap.set('n', '<leader>2', builtin.git_status, {})
vim.keymap.set('n', '<leader>3', builtin.git_bcommits, {})
vim.keymap.set('n', '<leader>4', builtin.git_commits, {})
vim.keymap.set('n', '<leader>g', builtin.lsp_definitions, {})
vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>l', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>d', function() builtin.diagnostics({ bufnr = 0 }) end, {})
EOF

"nvim-treesitter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "c", "cpp", "rust", "python", "cuda",
    "toml", "yaml", "json", "markdown", "dockerfile",
    "make", "cmake", "bash",
    "lua", "vim", "help"
  },
  highlight = { enable = true, },
}
EOF
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldcolumn=4
