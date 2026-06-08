-- blink.cmp — fast completion (Rust matcher). The modern nvim-cmp replacement.
return {
  "saghen/blink.cmp",
  version = "1.*", -- pull prebuilt fuzzy-matcher binaries
  dependencies = { "rafamadriz/friendly-snippets" },
  event = "InsertEnter",
  ---@module 'blink.cmp'
  opts = {
    keymap = { preset = "default" }, -- <C-y> accept, <C-n>/<C-p> select, <C-space> open
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      ghost_text = { enabled = true },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
