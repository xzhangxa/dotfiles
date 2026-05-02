return {
  "sindrets/diffview.nvim",
  config = function()
    vim.keymap.set('n', '<leader>1', ':DiffviewOpen -uno ', {})
    vim.keymap.set('n', '<leader>2', ':DiffviewFileHistory ', {})
    vim.keymap.set('n', '<leader>3', ':DiffviewClose<cr>', {})
  end,
}
