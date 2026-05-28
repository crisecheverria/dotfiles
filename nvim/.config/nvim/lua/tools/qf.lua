-- :Grep command + quickfix window ergonomics.
-- Contributes: options (grepprg=ag), usercmds (:Grep),
-- autocmds (auto-open qf, qf buffer keymaps).
-- In the qf window: `o` opens+centers+returns, `<Esc>` closes it.
-- Disable to lose :Grep; use :grep directly with default grepprg.

return {
	options = {
		grepprg = "ag --vimgrep --ignore '*mock*' --ignore tags",
		grepformat = "%f:%l:%c:%m",
	},
	autocmds = {
		{
			"QuickFixCmdPost",
			function()
				vim.cmd("cwindow 20")
			end,
		},
		{
			"Filetype",
			function()
				vim.keymap.set("n", "o", "<cr>zz<c-w>p", { buffer = true })
				vim.keymap.set("n", "<Esc>", "<cmd>cclose<cr>", { buffer = true })
				vim.wo.number = false
				vim.wo.relativenumber = false
				vim.wo.colorcolumn = ""
				vim.wo.cursorlineopt = "line"
			end,
			{ pattern = "qf" },
		},
	},
	usercmds = {
		{ "Grep", ":silent grep! '<args>'", { nargs = 1 } },
	},
}
