return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
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
  end,
}
