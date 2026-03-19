return {
	keymaps = {
		{ { "n" }, "<leader>g", ":Grep<space>", { desc = "Grep prompt" } },
		{ { "n" }, "<leader>G", ":Grep<space><cword><cr>", { desc = "Grep word under cursor" } },
		-- TODO: configure linting using :make or :compiler
		-- { { "n" }, "<leader>l", ":silent make!<space>" },
	},
	options = {
		grepprg = "ag --vimgrep --ignore '*mock*'",
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
