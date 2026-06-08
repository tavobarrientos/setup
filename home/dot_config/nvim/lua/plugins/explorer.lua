-- neo-tree — in-editor file explorer (yazi is still your standalone manager).
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>",         desc = "Explorer (toggle)" },
    { "<leader>o", "<cmd>Neotree focus<cr>",          desc = "Explorer (focus)" },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      filtered_items = { hide_dotfiles = false, hide_gitignored = true },
    },
    window = { width = 32 },
  },
}
