local terminal_state = { buf = nil, win = nil, is_open = false }

local function floating_terminal()
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	local has_terminal = false
	for _, line in ipairs(lines) do
		if line ~= "" then
			has_terminal = true
			break
		end
	end
	if not has_terminal then
		vim.fn.jobstart(os.getenv("SHELL"), { term = true })
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = terminal_state.buf,
		once = true,
		callback = function()
			if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
				vim.api.nvim_win_close(terminal_state.win, false)
				terminal_state.is_open = false
			end
		end,
	})
end

local function close_floating_terminal()
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, true)
	end
	if terminal_state.buf and vim.api.nvim_buf_is_valid(terminal_state.buf) then
		local job_id = vim.b[terminal_state.buf].terminal_job_id
		if job_id then
			vim.fn.jobstop(job_id)
		end
		vim.api.nvim_buf_delete(terminal_state.buf, { force = true })
	end
	terminal_state.buf = nil
	terminal_state.win = nil
	terminal_state.is_open = false
end

local function run_test()
	local file = vim.fn.expand("%:p")
	local ft = vim.bo.filetype
	local cmd

	if ft == "lua" then
		local minimal = vim.fn.findfile("tests/minimal_init.lua", vim.fn.getcwd() .. ";")
		if minimal ~= "" then
			cmd = "nvim --headless -u " .. minimal .. " -l " .. file
		else
			cmd = "nvim --headless -l " .. file
		end
	elseif ft == "python" then
		cmd = "python -m pytest " .. file .. " -v"
	elseif ft == "javascript" or ft == "typescript" then
		local dir = vim.fn.expand("%:p:h")
		local vitest = vim.fn.findfile("node_modules/.bin/vitest", dir .. ";")
		local jest = vim.fn.findfile("node_modules/.bin/jest", dir .. ";")
		if vitest ~= "" then
			cmd = vim.fn.fnamemodify(vitest, ":p") .. " run " .. file
		elseif jest ~= "" then
			cmd = vim.fn.fnamemodify(jest, ":p") .. " " .. file
		else
			cmd = "node --test " .. file
		end
	elseif ft == "go" then
		cmd = "go test " .. vim.fn.expand("%:h") .. "/..."
	else
		vim.notify("No test runner configured for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	vim.cmd("botright 15split")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, buf)
	vim.fn.jobstart(cmd, {
		term = true,
		on_exit = function(_, code)
			vim.schedule(function()
				local msg = code == 0 and "Tests passed" or "Tests FAILED (exit " .. code .. ")"
				local level = code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
				vim.notify(msg, level)
			end)
		end,
	})
	vim.cmd("startinsert")
end

local function run_async(opts)
	local cmd = opts.args
	vim.notify("Running: " .. cmd, vim.log.levels.INFO)
	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, code)
			vim.schedule(function()
				local status = code == 0 and "succeeded" or "FAILED (exit " .. code .. ")"
				local msg = cmd .. " " .. status
				-- Ghostty desktop notification via OSC 9
				vim.fn.chansend(vim.v.stderr, "\027]9;" .. msg .. "\007")
				-- Also show in-editor
				local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
				vim.notify(msg, level)
			end)
		end,
	})
end

local colorscheme_file = vim.fn.stdpath("data") .. "/colorscheme"

local function colorscheme_picker()
	local schemes = vim.fn.getcompletion("", "color")
	local original = vim.g.colors_name

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, schemes)
	vim.bo[buf].modifiable = false

	local width = 30
	local height = math.min(#schemes, math.floor(vim.o.lines * 0.6))
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Colorschemes ",
		title_pos = "center",
	})

	local function apply()
		local line = vim.api.nvim_win_get_cursor(win)[1]
		pcall(vim.cmd.colorscheme, schemes[line])
	end

	local function close(keep)
		if keep then
			local f = io.open(colorscheme_file, "w")
			if f then f:write(vim.g.colors_name or original) f:close() end
		else
			pcall(vim.cmd.colorscheme, original)
		end
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buf,
		callback = apply,
	})

	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<cr>", function() close(true) end, opts)
	vim.keymap.set("n", "q", function() close(false) end, opts)
	vim.keymap.set("n", "<esc>", function() close(false) end, opts)
end

local function lazygit()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = vim.o.columns
	local height = vim.o.lines - 1
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = 0,
		col = 0,
		style = "minimal",
		border = "rounded",
	})
	vim.fn.jobstart("lazygit", {
		term = true,
		on_exit = function()
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end)
		end,
	})
	vim.cmd("startinsert")
end

local function show_keymaps()
	local modes = { "n", "i", "v", "x", "o" }
	local lines = {}
	local leader = vim.g.mapleader or "\\"
	for _, mode in ipairs(modes) do
		local maps = vim.api.nvim_get_keymap(mode)
		for _, map in ipairs(maps) do
			local lhs = map.lhs:gsub(leader, "<leader>", 1)
			local rhs = map.rhs or (map.callback and "<function>" or "")
			local desc = map.desc or ""
			table.insert(lines, string.format("%-4s %-20s %-40s %s", mode, lhs, rhs, desc))
		end
	end
	table.sort(lines)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "conf"
	vim.bo[buf].modifiable = false

	vim.cmd("split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, silent = true })
end

return {
	autocmds = {
		{
			"TextYankPost",
			function() vim.highlight.on_yank() end,
		},
		{
			"VimResized",
			function() vim.cmd("tabdo wincmd =") end,
		},
		{
			"TermClose",
			function()
				if vim.v.event.status == 0 then
					vim.api.nvim_buf_delete(0, {})
				end
			end,
		},
		{
			"BufReadPost",
			function()
				local mark = vim.api.nvim_buf_get_mark(0, '"')
				local lcount = vim.api.nvim_buf_line_count(0)
				local line = mark[1]
				local ft = vim.bo.filetype
				if line > 0 and line <= lcount
					and vim.fn.index({ "commit", "gitrebase", "xxd" }, ft) == -1
					and not vim.o.diff then
					pcall(vim.api.nvim_win_set_cursor, 0, mark)
				end
			end,
		},
	},
	usercmds = {
		{
			"ConfigReload",
			function()
				vim.cmd.source(vim.env.MYVIMRC)
				vim.cmd.doautocmd("User ConfigReload")
				vim.cmd.doautoall("Config Filetype")
			end,
		},
		{ "Keymaps", show_keymaps, {} },
		{ "FloatingTerminal", floating_terminal, {} },
		{ "CloseFloatingTerminal", close_floating_terminal, {} },
		{ "ColorPicker", colorscheme_picker, {} },
		{ "RunTest", run_test, {} },
		{ "Lazygit", lazygit, {} },
		{ "Run", run_async, { nargs = "+" } },
	},
}
