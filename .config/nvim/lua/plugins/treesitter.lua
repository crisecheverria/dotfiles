vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require "nvim-treesitter.configs".setup({
	ensure_installed = { "go", "python", "typescript", "javascript" },
	highlight = { enable = true }
})
