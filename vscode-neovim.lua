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
vim.opt.cursorline = true
vim.opt.colorcolumn = { '80', '120' }
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 5
vim.fn.matchadd('ErrorMsg', '\\s\\+$')

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})
