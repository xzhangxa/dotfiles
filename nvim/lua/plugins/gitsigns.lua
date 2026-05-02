return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({})
    vim.keymap.set('n', '<leader>4', ':Gitsigns blame<cr>', {})
  end,
}
