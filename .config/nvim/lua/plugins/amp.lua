vim.pack.add({ "https://github.com/sourcegraph/amp.nvim" }, { branch = "main", load = true })

require("amp").setup({
	auto_start = true,
	log_level = "error",
})
