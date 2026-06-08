-- LSP: mason (installer) + mason-lspconfig (bridge) + native vim.lsp.config.
--
-- Neovim 0.11+ owns LSP config now: we describe servers with vim.lsp.config()
-- and mason-lspconfig's `automatic_enable` calls vim.lsp.enable() for each
-- installed server. The old require("lspconfig").x.setup{} pattern is gone.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    -- Per-buffer keymaps, set when any server attaches.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(event)
        local buf = event.buf
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = buf, desc = "LSP: " .. desc })
        end

        map("grn", vim.lsp.buf.rename, "Rename")
        map("gra", vim.lsp.buf.code_action, "Code action")
        map("grr", vim.lsp.buf.references, "References")
        map("gri", vim.lsp.buf.implementation, "Implementation")
        map("grd", vim.lsp.buf.definition, "Definition")
        map("grD", vim.lsp.buf.declaration, "Declaration")
        map("gO",  vim.lsp.buf.document_symbol, "Document symbols")
        map("K",   vim.lsp.buf.hover, "Hover")
        map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Let pyright own hover; ruff is just the linter/formatter.
        if client and client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end

        -- Highlight references of the symbol under the cursor.
        if client and client:supports_method("textDocument/documentHighlight") then
          local hl = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = hl, buffer = buf, callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = hl, buffer = buf, callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- Advertise blink.cmp's completion capabilities to every server.
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    -- Per-server overrides (merged on top of "*"). Names = lspconfig configs.
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false },
          diagnostics = { globals = { "vim" } }, -- silence "undefined global vim"
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = { typeCheckingMode = "basic", autoImportCompletions = true },
        },
      },
    })

    -- mason installs these; automatic_enable (default) then vim.lsp.enable()s them.
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",     -- Lua (this config)
        "omnisharp",  -- C# / .NET
        "ts_ls",      -- TypeScript / JavaScript
        "eslint",     -- JS/TS linting
        "pyright",    -- Python types
        "ruff",       -- Python lint + format
      },
      automatic_enable = true,
    })
  end,
}
