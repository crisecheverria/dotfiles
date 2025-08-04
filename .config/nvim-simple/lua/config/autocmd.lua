-- Autoformat on save (:w)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("erock.cfg", { clear = true }),
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
