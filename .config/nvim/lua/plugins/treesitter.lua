vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" } }, { load = true })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if require("nvim-treesitter.configs") then
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"rust",
					"javascript",
					"typescript",
					"python",
					"go",
					"lua",
					"html",
					"css",
					"json",
					"yaml",
					"toml",
					"markdown",
				},
				auto_install = true,
			})
		end
	end,
})
