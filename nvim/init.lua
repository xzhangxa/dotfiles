-- disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "

if not vim.g.vscode then
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

  require("lazy").setup("plugins")
end

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
if not vim.g.vscode then
  vim.opt.background = 'dark'
  vim.cmd.colorscheme('gruvbox')
end
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

-- auto-session
-------------------------------------------------------------------------------
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- nvim-treesitter
-------------------------------------------------------------------------------
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldcolumn = '4'

-- terminal
-------------------------------------------------------------------------------
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    set_terminal_keymaps()
    vim.cmd.startinsert()
  end,
})
