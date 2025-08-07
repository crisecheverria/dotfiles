-- Autoformat on save (:w)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("erock.cfg", { clear = true }),
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
