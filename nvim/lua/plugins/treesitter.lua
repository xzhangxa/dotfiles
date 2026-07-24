return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter').install {
      'c', 'cpp', 'rust', 'python', 'cuda', 'asm', 'devicetree',
      'toml', 'yaml', 'json', 'markdown', 'dockerfile',
      'make', 'cmake', 'meson', 'bash', 'llvm',
      'lua', 'vim', 'vimdoc'
    }
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { '<filetype>' },
      callback = function() vim.treesitter.start() end,
    })
  end,
}
