return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter').install {
      'cpp', 'rust', 'python', 'cuda', 'asm', 'devicetree',
      'toml', 'yaml', 'json', 'dockerfile',
      'make', 'cmake', 'meson', 'bash', 'llvm'
    }
    vim.api.nvim_create_autocmd('FileType', {
      -- Start highlighting when a parser for the buffer's filetype is
      -- installed; pcall silently skips filetypes without one.
      callback = function(args) pcall(vim.treesitter.start, args.buf) end,
    })
  end,
}
