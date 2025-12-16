vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
}, { load = true })

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"gopls",
		"pyright",
		"eslint",
		"vtsls",
		"lua_ls",
		"rust_analyzer",
		"stylua",
		"bashls",
		"sqlls",
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

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
			},
			checkOnSave = {
				command = "clippy",
			},
		},
	},
})

-- Enable LSP servers automatically
vim.lsp.enable({
	"gopls",
	"pyright",
	"eslint",
	"vtsls",
	"lua_ls",
	"rust_analyzer",
	"stylua",
	"bashls",
	"sqlls",
})

-- Diagnostics configuration
vim.diagnostic.config({
	virtual_lines = {
		current_line = true,
	},
})
