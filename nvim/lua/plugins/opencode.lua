local marker = vim.fn.stdpath("config") .. "/.opencode-enabled"
if not vim.uv.fs_stat(marker) then
  return {}
end

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    {
      "folke/snacks.nvim",
      opts = {
        input = {
          enabled = true,
        },
        picker = {
          enabled = true,
          actions = {
            ---@param picker snacks.Picker
            opencode_send = function(picker)
              local items = vim.tbl_map(function(item) ---@param item snacks.picker.Item
                return item.file
                  and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                  or item.text
              end, picker:selected({ fallback = true }))

              require("opencode").prompt(table.concat(items, ", ") .. " ")
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    local opencode_cmd = "opencode --port"
    local snacks_terminal_opts = {
      win = {
        position = "right",
        enter = false,
      },
    }

    vim.g.opencode_opts = {
      server = {
        start = function()
          require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }

    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-\\>", function()
      require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
  end,
}
