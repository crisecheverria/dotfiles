vim.pack.add({ "https://github.com/nemanjamalesija/ts-expand-hover.nvim" })

require("ts_expand_hover").setup({
	ft = { "typescript", "typescriptreact" },
})
