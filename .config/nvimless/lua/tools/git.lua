local function git_output(cmd, title)
	local result = vim.system(cmd, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return
	end

	local lines = vim.split(result.stdout, "\n", { trimempty = true })
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_set_name(buf, title)

	vim.cmd("split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, silent = true })
end

return {
	usercmds = {
		{
			"Gstatus",
			function()
				git_output({ "git", "status" }, "git:status")
			end,
			{ desc = "Git status" },
		},
		{
			"Gdiff",
			function(args)
				local cmd = { "git", "diff" }
				if args.args ~= "" then
					table.insert(cmd, args.args)
				end
				git_output(cmd, "git:diff")
			end,
			{ nargs = "?", desc = "Git diff (optional file)" },
		},
		{
			"Glog",
			function()
				git_output({ "git", "log", "--oneline", "--graph", "--decorate", "-50" }, "git:log")
			end,
			{ desc = "Git log (last 50)" },
		},
		{
			"Gblame",
			function()
				local file = vim.api.nvim_buf_get_name(0)
				local result = vim.system({ "git", "blame", file }, { text = true }):wait()
				if result.code ~= 0 then
					vim.notify(result.stderr, vim.log.levels.ERROR)
					return
				end

				local source_win = vim.api.nvim_get_current_win()
				local cursor = vim.api.nvim_win_get_cursor(source_win)

				local lines = vim.split(result.stdout, "\n", { trimempty = true })
				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
				vim.bo[buf].modifiable = false
				vim.api.nvim_buf_set_name(buf, "git:blame")

				vim.cmd("leftabove vsplit")
				local blame_win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(blame_win, buf)
				vim.api.nvim_win_set_cursor(blame_win, cursor)

				-- Sync scrolling between blame and source
				vim.wo[blame_win].scrollbind = true
				vim.wo[source_win].scrollbind = true
				vim.wo[blame_win].cursorbind = true
				vim.wo[source_win].cursorbind = true
				vim.wo[blame_win].number = false
				vim.wo[blame_win].relativenumber = false
				vim.wo[blame_win].wrap = false

				-- Close blame and restore source window bindings on q
				vim.keymap.set("n", "q", function()
					vim.wo[source_win].scrollbind = false
					vim.wo[source_win].cursorbind = false
					vim.cmd("bdelete")
				end, { buffer = buf, silent = true })
			end,
			{ desc = "Git blame current file (side by side)" },
		},
		{
			"Gcommits",
			function()
				local file = vim.api.nvim_buf_get_name(0)
				git_output({ "git", "log", "--oneline", "--follow", file }, "git:commits")
			end,
			{ desc = "Git commits for current file" },
		},
	},
	keymaps = {
		{ { "n" }, "<leader>gs", "<cmd>Gstatus<cr>", { desc = "Git status" } },
		{ { "n" }, "<leader>gd", "<cmd>Gdiff<cr>", { desc = "Git diff" } },
		{ { "n" }, "<leader>gl", "<cmd>Glog<cr>", { desc = "Git log" } },
		{ { "n" }, "<leader>gb", "<cmd>Gblame<cr>", { desc = "Git blame" } },
		{ { "n" }, "<leader>gc", "<cmd>Gcommits<cr>", { desc = "Git commits for file" } },
	},
}
