vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" }
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls",
    "pyright",
    "eslint",
    "vtsls",
    "lua_ls",
  },
})

-- Disable vim undefined warnings
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

-- Diagnostics configuration
vim.diagnostic.config({
  virtual_lines = {
    current_line = true
  }
})
