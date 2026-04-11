-- disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

local servers = {
  "clangd",
  "neocmake",
  "rust_analyzer",
  "asm_lsp",
}

require("lazy").setup({
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  { "akinsho/toggleterm.nvim", config = true },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- git signs in gutter
  { "lewis6991/gitsigns.nvim", config = true },
  -- git diff
  "sindrets/diffview.nvim",
  -- auto close quotes, brackets
  "windwp/nvim-autopairs",
  -- lsp
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = servers,
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  -- fuzzy finder and many things else
  "nvim-lua/plenary.nvim",
  "nvim-telescope/telescope.nvim",
  "nvim-telescope/telescope-ui-select.nvim",
  { "nvim-treesitter/nvim-treesitter", branch = "master", lazy = false, build = ":TSUpdate" },
  -- folder navigation
  "nvim-tree/nvim-tree.lua",
  -- session
  { "rmagatti/auto-session", lazy = false },
})

-- neovim basic/misc. settings
-------------------------------------------------------------------------------
vim.opt.clipboard = 'unnamedplus'
vim.opt.jumpoptions = 'stack'
vim.opt.diffopt = {"vertical", "internal", "filler", "closeoff", "linematch:40"}

-- indent
vim.opt.smartindent = true
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- set very magic for regular expression
vim.keymap.set('n', '/', '/\\v', {})
vim.keymap.set('n', '?', '?\\v', {})
vim.keymap.set('c', 's/', 's/\\v', {})
-- search visual selected word
vim.keymap.set('v', '/', 'y/<C-r>"<CR>', {})
vim.keymap.set('v', '?', 'y?<C-r>"<CR>', {})

-- ui, color, etc.
vim.opt.background = 'dark'
vim.cmd.colorscheme('gruvbox')
vim.opt.cursorline = true
vim.opt.colorcolumn = { '80', '120' }
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 5
vim.fn.matchadd('ErrorMsg', '\\s\\+$')

-- lsp, diagnostic
vim.keymap.set({'n', 'v'}, '<leader>5', vim.lsp.buf.format)
-- neovim default: <C-S> in Insert and Select mode maps to vim.lsp.buf.signature_help()
-- neovim default: K in Normal mode maps to vim.lsp.buf.hover()
-- neovim default: gra in Normal/Visual mode maps to vim.lsp.buf.code_action()
-- neovim default: grn maps to vim.lsp.buf.rename()
-- neovim default: gri maps to vim.lsp.buf.implementation()
-- neovim default: grr maps to vim.lsp.buf.references()
-- neovim default: grt maps to vim.lsp.buf.type_definition()

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})

-- auto completion
vim.opt.autocomplete = true
vim.opt.pumborder = 'rounded'
vim.opt.pummaxwidth = 40
vim.opt.complete = ".^5,w^5,b^5,u^5,i^5"
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }
vim.keymap.set('i', '<Tab>',
  function()
    return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
  end,
  { noremap = true, expr = true }
)
vim.keymap.set('i', '<S-Tab>',
  function()
    return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
  end,
  { noremap = true, expr = true }
)

-- remember and open at the pos of the file when last time closed
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= lcount then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- per language
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "c", "cpp" },
--   callback = function()
--     vim.opt_local.expandtab = false
--     vim.opt_local.shiftwidth = 8
--     vim.opt_local.softtabstop = 8
--   end,
-- })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- lualine
-------------------------------------------------------------------------------
require('lualine').setup {
  options = { theme = 'gruvbox' },
}

-- diffview
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>1', ':DiffviewOpen -uno ', {})
vim.keymap.set('n', '<leader>2', ':DiffviewFileHistory ', {})
vim.keymap.set('n', '<leader>3', ':DiffviewClose<cr>', {})

-- gitsigns
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>4', ':Gitsigns blame<cr>', {})

-- nvim-tree
-------------------------------------------------------------------------------
require("nvim-tree").setup({
  tab = {
    sync = {
      open = true,
      close = true,
    },
  },
  update_focused_file = {
    enable = true,
    update_root = {
      enable = true,
    },
  },
})
vim.keymap.set('n', '<leader>F', ':NvimTreeFindFile!<cr>', {})

-- auto-session
-------------------------------------------------------------------------------
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
require('auto-session').setup {
  suppressed_dirs = { "~/", "~/Downloads", "/" },
  pre_save_cmds = {
    function() require('nvim-tree.api').tree.close() end
  },
  pre_restore_cmds = {
    function() require('nvim-tree.api').tree.close() end
  },
  post_restore_cmds = {
    function() require("nvim-tree.api").tree.toggle({ focus = false, find_file = true }) end
  },
}

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
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        -- even more opts
      }
    }
  }
}
require("telescope").load_extension("ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>f', function() builtin.find_files({ default_text = vim.fn.expand('%:~:.:h') }) end, {})
vim.keymap.set('n', '<leader>w', function() builtin.grep_string({ word_match = "-w" }) end, {})
vim.keymap.set('n', '<leader>s', builtin.grep_string, {})
vim.keymap.set('n', '<leader>S', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>o', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>m', function() builtin.man_pages({ sections = { "ALL" } }) end, {})
vim.keymap.set('n', '<leader>g', builtin.lsp_definitions, {})
vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>l', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>d', function() builtin.diagnostics({ bufnr = 0 }) end, {})

-- nvim-treesitter
-------------------------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "c", "cpp", "rust", "python", "cuda", "asm", "devicetree",
    "toml", "yaml", "json", "markdown", "dockerfile",
    "make", "cmake", "meson", "bash", "llvm",
    "lua", "vim", "vimdoc",
  },
  highlight = { enable = true, },
}
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldcolumn = '4'

-- bufferline
-------------------------------------------------------------------------------
require("bufferline").setup {
  options = {
    numbers = "buffer_id",
    separator_style = "slant",
    indicator = {
      icon = '▎',
      style = 'icon',
    },
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "left",
        separator = true,
      }
    },
  }
}

-- toggleterm
-------------------------------------------------------------------------------
require("toggleterm").setup{
  open_mapping = [[<c-\>]],
  direction = 'float',
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  close_on_exit = true,
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = set_terminal_keymaps,
})
