-- Treesitter: syntax highlighting, indentation, incremental selection.
--
-- Pinned to the `master` branch. The `main` branch is the future rewrite but
-- its API is still settling; master's configs.setup{} is stable today. Switch
-- to main once it stabilises (it will become the default branch upstream).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "bash", "c", "c_sharp", "css", "diff", "dockerfile", "gitignore",
      "html", "javascript", "json", "jsonc", "lua", "luadoc", "markdown",
      "markdown_inline", "python", "query", "regex", "toml", "tsx",
      "typescript", "vim", "vimdoc", "yaml",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection    = "<C-space>",
        node_incremental  = "<C-space>",
        node_decremental  = "<bs>",
      },
    },
  },
}
