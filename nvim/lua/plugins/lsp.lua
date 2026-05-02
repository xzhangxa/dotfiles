local servers = {
  "clangd",
  "neocmake",
}

return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = servers,
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
}
