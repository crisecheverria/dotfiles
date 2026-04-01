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
		{
			"Grep",
			function(opts)
				local pattern = opts.args
				local cmd = vim.o.grepprg .. " " .. vim.fn.shellescape(pattern)
				local lines = {}

				vim.api.nvim_ui_send("\027]9;4;3\027\\")

				vim.fn.jobstart(cmd, {
					on_stdout = function(_, data)
						for _, line in ipairs(data) do
							if line ~= "" then
								table.insert(lines, line)
							end
						end
					end,
					on_exit = function()
						vim.api.nvim_ui_send("\027]9;4;0\027\\")
						if #lines > 0 then
							vim.fn.setqflist({}, " ", {
								title = "Grep: " .. pattern,
								lines = lines,
								efm = vim.o.grepformat,
							})
							vim.notify(#lines .. " matches for '" .. pattern .. "'")
							vim.cmd("cwindow 20")
						else
							vim.notify("No matches for '" .. pattern .. "'")
						end
					end,
				})
			end,
			{ nargs = 1 },
		},
	},
}
