-- Core editor settings (vim.opt). Loaded before plugins.
local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"   -- avoid layout shift when diagnostics appear
opt.termguicolors  = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.splitright     = true
opt.splitbelow     = true
opt.winborder      = "rounded"

-- Indentation
opt.expandtab   = true
opt.shiftwidth  = 2
opt.tabstop     = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = false
opt.incsearch  = true

-- Editing behaviour
opt.clipboard    = "unnamedplus"   -- share with system clipboard
opt.undofile     = true            -- persistent undo
opt.swapfile     = false
opt.updatetime   = 250
opt.timeoutlen   = 400
opt.confirm      = true            -- prompt instead of failing on :q with unsaved
opt.mouse        = "a"
opt.completeopt  = "menu,menuone,noselect"

-- Show invisible chars
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Decide diagnostics display once, globally.
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
})
