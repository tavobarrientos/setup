-- Neovim config — managed by chezmoi.
-- Hand-rolled, modular, lazy.nvim based. Targets Neovim 0.11+ (native vim.lsp).
--
--   init.lua            -> this entry point
--   lua/config/         -> options, keymaps, autocmds, lazy bootstrap
--   lua/plugins/        -> one file per concern, auto-imported by lazy

-- Leader must be set BEFORE lazy.nvim loads so plugin mappings pick it up.
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
