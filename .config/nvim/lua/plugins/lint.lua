vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { load = true })

require("lint").linters_by_ft = {
	go = { "golangcilint" },
}

-- Run linter on save and when entering a buffer
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
