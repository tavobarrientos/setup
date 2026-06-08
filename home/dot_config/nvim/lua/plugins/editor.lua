-- Editing quality-of-life plugins.
return {
  -- Keybinding hints popup.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
      },
    },
  },

  -- Comment toggling (gcc / gc in visual).
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },

  -- Auto-close brackets/quotes, integrates with blink/treesitter.
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Add/change/delete surrounding pairs (ys, cs, ds).
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },

  -- Highlight + search TODO/FIXME/HACK comments.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find todos" },
    },
  },
}
