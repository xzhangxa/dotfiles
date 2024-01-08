-- disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "morhetz/gruvbox",
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- git mark shower
  "airblade/vim-gitgutter",
  -- auto close quotes, brackets
  "windwp/nvim-autopairs",
  -- comments shortcuts
  "preservim/nerdcommenter",
  -- lsp
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  -- fuzzy finder and many things else
  "nvim-lua/plenary.nvim",
  "nvim-telescope/telescope.nvim",
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  -- completer, snippets
  { "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
    },
  },
  -- folder navigation
  "nvim-tree/nvim-tree.lua",
  -- session
  "mhinz/vim-startify",
})

-- neovim basic/misc. settings
-------------------------------------------------------------------------------
vim.cmd('filetype plugin indent on')
vim.opt.clipboard = 'unnamedplus'
vim.opt.jumpoptions = 'stack'

-- indent
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
-- set very magic for regular expression
vim.keymap.set('n', '/', '/\\v', {})
vim.keymap.set('n', '?', '?\\v', {})
vim.keymap.set('c', 's/', 's/\\v', {})
-- search visual selected word
vim.keymap.set('v', '/', 'y/<C-r>"<CR>', {})
vim.keymap.set('v', '?', 'y?<C-r>"<CR>', {})

-- terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', {})
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', {})
vim.keymap.set('n', 'T', ':split | terminal<CR>i', {})

-- ui, color, etc.
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.cmd.colorscheme('gruvbox')
vim.opt.cursorline = true
vim.opt.colorcolumn = { '80', '120' }
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.laststatus = 2
vim.opt.number = true
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 5
vim.cmd([[
  syntax enable
  match ErrorMsg "\s\+$"
]])

-- remember and open at the pos of the file when last time closed
vim.cmd([[
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif
]])

-- setup quickfix window size
vim.cmd([[
augroup qfwin
    autocmd!
    autocmd FileType qf call AdjustWindowHeight(3, 20)
augroup END
function! AdjustWindowHeight(minheight, maxheight)
    execute max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
]])

-- per language
-- autocmd FileType c setlocal noexpandtab shiftwidth=8 softtabstop=8
vim.cmd([[
  autocmd FileType dts setlocal foldmethod=indent foldignore=
]])

-- lualine
-------------------------------------------------------------------------------
require('lualine').setup {
    options = { theme = 'gruvbox' },
}

-- vim-gitgutter
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>1', ':GitGutterDiffOrig<cr>', {})

-- nvim-tree
-------------------------------------------------------------------------------
require("nvim-tree").setup()
vim.keymap.set('n', '<leader>F', ':NvimTreeFindFile!<cr>', {})
local function open_nvim_tree(data)
  -- buffer is a real file on the disk
  local real_file = vim.fn.filereadable(data.file) == 1
  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
  if not real_file and not no_name then
    return
  end
  -- change to file's directory if it's not under cwd
  local file_dir = vim.fn.fnamemodify(data.file, ':p:h')
  local cwd = vim.fn.getcwd()
  if not string.find(file_dir, cwd, 1, true) then
    vim.cmd.cd(file_dir)
  end
  -- open the tree, find the file but don't focus it
  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
end
-- Open nvim-tree when open nvim using the function above
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- startify
-------------------------------------------------------------------------------
vim.g['startify_session_persistence'] = 1

-- nvim-cmp
-------------------------------------------------------------------------------
local cmp = require('cmp')

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
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- nvim-lspconfig
-- mason
-- mason-lspconfig
-------------------------------------------------------------------------------
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
  vim.keymap.set({'n', 'v'}, '<leader>5', vim.lsp.buf.format, opts)
  vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float, opts)

  if client.server_capabilities.document_highlight then
    vim.cmd([[
      hi LspReferenceRead cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828
      hi LspReferenceText cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828
      hi LspReferenceWrite cterm=reverse ctermfg=214 ctermbg=235 gui=reverse guifg=#fabd2f guibg=#282828
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]])
  end
end

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end
vim.opt.updatetime = 2000

-- nvim-autopairs
-------------------------------------------------------------------------------
require('nvim-autopairs').setup{}

-- nvim-telescope
-------------------------------------------------------------------------------
local actions = require("telescope.actions")
require("telescope").setup {
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
vim.keymap.set('n', '<leader>dl', function() builtin.diagnostics({ bufnr = 0 }) end, {})

-- nvim-treesitter
-------------------------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "c", "cpp", "rust", "python", "cuda",
    "toml", "yaml", "json", "markdown", "dockerfile",
    "make", "cmake", "bash",
    "lua", "vim", "vimdoc"
  },
  highlight = { enable = true, },
}
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldcolumn = '4'

-- bufferline
-------------------------------------------------------------------------------
require("bufferline").setup {
  options = {
    numbers = "buffer_id",
    separator_style = "thick",
    indicator = {
      icon = '▎',
      style = 'icon',
    },
  }
}
