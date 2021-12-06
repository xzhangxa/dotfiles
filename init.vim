" set vim-plug
call plug#begin()

" git wrapper
Plug 'tpope/vim-fugitive'
" vcs mark shower
Plug 'mhinz/vim-signify'
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
Plug 'williamboman/nvim-lsp-installer'
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

"terminal
tnoremap <Esc> <C-\><C-n>
tnoremap <C-w> <C-\><C-n><C-w>
nnoremap T :split \| terminal<CR>i

"ui, color, font, etc.
syntax enable
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
set background=dark
colorscheme gruvbox
set cursorline
set colorcolumn=80,120
set foldmethod=syntax
set foldcolumn=4
match ErrorMsg '\s\+$'
highlight CursorLine term=bold cterm=bold ctermbg=black

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
autocmd FileType python setlocal foldmethod=indent foldignore=

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

"vim-signify
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>2 :SignifyDiff<CR>

"nerdtree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>F :NERDTreeToggle<CR>

"startify
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:startify_session_persistence = 1

"nvim-lspconfig
"nvim-lsp-installer
"nvim-cmp
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
local cmp = require'cmp'

local has_words_before = function()
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
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true
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
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local lsp_installer = require "nvim-lsp-installer"

local servers = {
  "clangd",
  "rust_analyzer",
}

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>n', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>p', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  if client.resolved_capabilities.document_highlight then
    vim.cmd [[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end
end

for _, name in pairs(servers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found then
    server:on_ready(function ()
      local opts = {
        capabilities = capabilities,
        on_attach = on_attach,
      }
      server:setup(opts)
    end)
  end
end
EOF

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
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  }
}
EOF
nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>s <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>S <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>m <cmd>lua require('telescope.builtin').man_pages({ sections = { "ALL" } })<cr>
nnoremap <leader>1 <cmd>lua require('telescope.builtin').git_status()<cr>
nnoremap <leader>3 <cmd>lua require('telescope.builtin').git_bcommits()<cr>
nnoremap <leader>4 <cmd>lua require('telescope.builtin').git_commits()<cr>
nnoremap <leader>g <cmd>lua require('telescope.builtin').lsp_definitions()<cr>
nnoremap <leader>r <cmd>lua require('telescope.builtin').lsp_references()<cr>
nnoremap <leader>l <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <leader>d <cmd>lua require('telescope.builtin').lsp_document_diagnostics()<cr>
