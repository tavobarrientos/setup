-- Catppuccin — matches the yazi flavor.
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- load before other plugins so highlights are correct
  opts = {
    flavour = "mocha",
    background = { light = "latte", dark = "mocha" },
    integrations = {
      blink_cmp = true,
      gitsigns = true,
      mason = true,
      native_lsp = { enabled = true },
      neotree = true,
      telescope = true,
      treesitter = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
