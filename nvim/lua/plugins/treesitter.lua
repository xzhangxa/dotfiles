return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = {
        "c", "cpp", "rust", "python", "cuda", "asm", "devicetree",
        "toml", "yaml", "json", "markdown", "dockerfile",
        "make", "cmake", "meson", "bash", "llvm",
        "lua", "vim", "vimdoc",
      },
      highlight = { enable = true, },
    }
  end,
}
