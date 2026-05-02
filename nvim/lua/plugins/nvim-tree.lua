return {
  "nvim-tree/nvim-tree.lua",
  config = function()
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
  end,
}
