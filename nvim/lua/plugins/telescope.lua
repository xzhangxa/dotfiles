return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local actions = require("telescope.actions")
    require("telescope").setup {
      defaults = {
        dynamic_preview_title = true,
        mappings = {
          i = {
            ["<esc>"] = actions.close
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {
            -- even more opts
          }
        }
      }
    }
    require("telescope").load_extension("ui-select")

    local builtin = require("telescope.builtin")
    vim.keymap.set('n', '<leader>f', function() builtin.find_files({ default_text = vim.fn.expand('%:~:.:h') }) end, {})
    vim.keymap.set('n', '<leader>w', function() builtin.grep_string({ word_match = "-w" }) end, {})
    vim.keymap.set('n', '<leader>s', builtin.grep_string, {})
    vim.keymap.set('n', '<leader>S', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>b', builtin.buffers, {})
    vim.keymap.set('n', '<leader>o', builtin.oldfiles, {})
    vim.keymap.set('n', '<leader>m', function() builtin.man_pages({ sections = { "ALL" } }) end, {})
    vim.keymap.set('n', '<leader>g', builtin.lsp_definitions, {})
    vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
    vim.keymap.set('n', '<leader>l', builtin.lsp_document_symbols, {})
    vim.keymap.set('n', '<leader>d', function() builtin.diagnostics({ bufnr = 0 }) end, {})
  end,
}
