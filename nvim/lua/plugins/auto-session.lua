return {
  "rmagatti/auto-session",
  lazy = false,
  config = function()
    require('auto-session').setup {
      suppressed_dirs = { "~/", "~/Downloads", "/" },
      pre_save_cmds = {
        function() require('nvim-tree.api').tree.close() end
      },
      pre_restore_cmds = {
        function() require('nvim-tree.api').tree.close() end
      },
      post_restore_cmds = {
        function() require("nvim-tree.api").tree.toggle({ focus = false, find_file = true }) end
      },
    }
  end,
}
