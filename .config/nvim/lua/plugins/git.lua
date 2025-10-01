vim.pack.add({
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
})

require("gitsigns").setup({
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
})
