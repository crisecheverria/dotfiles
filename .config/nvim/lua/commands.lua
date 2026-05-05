-- Custom :user commands and general autocmds not tied to a language/tool.
-- Contributes: autocmds, usercmds.
-- Commands: :FloatingTerminal, :CloseFloatingTerminal, :RunTest, :RunFile,
-- :Run, :Lazygit, :ColorPicker, :Keymaps, :ConfigReload, :UpdateQueries,
-- :Cht, :Docs.
-- Autocmds: yank highlight, resize equalize, term-close cleanup, restore
-- cursor to last position. Disabling loses :RunFile/:RunTest and the
-- floating terminal/lazygit/colorscheme pickers.

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

local function run_file()
	vim.cmd("silent! write")
	local ft = vim.bo.filetype
	local file = vim.fn.shellescape(vim.fn.expand("%:p"))
	local stem = vim.fn.shellescape(vim.fn.expand("%:p:r"))
	local cmd
	if ft == "cpp" then
		cmd = ("g++ -std=c++20 -O0 -g %s -o %s && %s"):format(file, stem, stem)
	elseif ft == "c" then
		cmd = ("gcc -std=c17 -O0 -g %s -o %s && %s"):format(file, stem, stem)
	elseif ft == "python" then
		cmd = "python3 " .. file
	elseif ft == "go" then
		cmd = "go run " .. file
	elseif ft == "rust" then
		cmd = "cargo run"
	elseif ft == "javascript" or ft == "typescript" then
		cmd = "node " .. file
	elseif ft == "lua" then
		cmd = "lua " .. file
	elseif ft == "sh" or ft == "bash" or ft == "zsh" then
		cmd = ft .. " " .. file
	else
		vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	vim.cmd("botright 15split | enew")
	vim.b.keep_term = true
	vim.fn.jobstart(cmd, {
		term = true,
		on_exit = function(_, code)
			vim.schedule(function()
				local msg = code == 0 and "Run succeeded" or "Run FAILED (exit " .. code .. ")"
				local level = code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
				vim.notify(msg, level)
			end)
		end,
	})
	vim.cmd("stopinsert")
end

local function run_async(opts)
	local cmd = vim.fn.expandcmd(opts.args)
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
	vim.cmd("enew | put =execute('map')")
	vim.bo.modifiable = false
	vim.bo.buftype = "nofile"
	vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = 0, silent = true })
end

-- :Docs [pattern] — browse ~/docs/ scoped to current buffer's filetype.
-- No args: file picker. With args: live-grep pre-filled with the pattern.
-- :Docs! (bang) widens scope to every subdir of ~/docs/.
local docs_by_ft = {
	javascript      = { "mdn" },
	javascriptreact = { "mdn", "react" },
	typescript      = { "ts", "mdn" },
	typescriptreact = { "ts", "mdn", "react" },
	cpp             = { "cpp-guidelines" },
	c               = { "cpp-guidelines" },
}
local function docs(opts)
	local cwd = vim.fn.expand("~/docs")
	if vim.fn.isdirectory(cwd) == 0 then
		vim.notify("Docs: ~/docs/ doesn't exist. Run `fetch-docs <lang>` first.", vim.log.levels.WARN)
		return
	end
	local dirs = {}
	if not opts.bang then
		for _, sub in ipairs(docs_by_ft[vim.bo.filetype] or {}) do
			local p = cwd .. "/" .. sub
			if vim.fn.isdirectory(p) == 1 then
				dirs[#dirs + 1] = p
			end
		end
	end
	if #dirs == 0 then
		dirs = { cwd }
	end
	if opts.args == "" then
		Snacks.picker.files({ dirs = dirs })
	else
		Snacks.picker.grep({ dirs = dirs, search = opts.args })
	end
end

-- :Cht <topic...> — fetch cheat.sh into a scratch split.
-- Single arg uses the current buffer's filetype as the language path:
--   :Cht map               -> cht.sh/typescript/map  (in a .ts buffer)
-- Multi-arg treats the first as the language, rest as topic words:
--   :Cht python list comprehension -> cht.sh/python/list+comprehension
local function cht(opts)
	local args = opts.fargs
	if #args == 0 then
		vim.notify("Cht: provide a topic", vim.log.levels.WARN)
		return
	end
	local ft_alias = {
		typescriptreact = "typescript",
		javascriptreact = "javascript",
		sh = "bash",
	}
	local lang, topic
	if #args == 1 then
		lang = ft_alias[vim.bo.filetype] or vim.bo.filetype
		topic = args[1]
	else
		lang = args[1]
		topic = table.concat(vim.list_slice(args, 2), "+")
	end
	local url = "https://cht.sh/" .. (lang ~= "" and (lang .. "/") or "") .. topic .. "?T"

	vim.notify("Cht: fetching " .. url)
	vim.system(
		{ "curl", "-fsSL", url },
		{ text = true },
		vim.schedule_wrap(function(res)
			if res.code ~= 0 then
				vim.notify("Cht failed (" .. res.code .. "): " .. (res.stderr or ""), vim.log.levels.ERROR)
				return
			end
			vim.cmd("botright 20split")
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(0, buf)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout, "\n", { plain = true }))
			vim.bo[buf].modifiable = false
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].filetype = lang or ""
			vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, silent = true })
		end)
	)
end

-- Refresh treesitter query files from nvim-treesitter master.
-- No args: refresh every language dir already under queries/.
-- With args: refresh only the listed languages (e.g. :UpdateQueries rust go).
-- Uses curl --fail --remove-on-error so 4xx responses leave no file behind
-- (some kinds like textobjects.scm aren't in upstream for every language).
local function update_queries(opts)
	local queries_dir = vim.fn.stdpath("config") .. "/queries"
	local langs = opts.fargs
	if #langs == 0 then
		for name, t in vim.fs.dir(queries_dir) do
			if t == "directory" then
				langs[#langs + 1] = name
			end
		end
	end
	if #langs == 0 then
		vim.notify("UpdateQueries: no language dirs found in " .. queries_dir, vim.log.levels.WARN)
		return
	end

	local kinds = { "highlights", "injections", "locals", "folds", "indents", "textobjects" }
	local base = "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/queries"
	local total = #langs * #kinds
	local pending = total
	local stats = { ok = 0, failed = 0 }

	vim.notify(string.format("UpdateQueries: fetching %d files for %d langs…", total, #langs))

	for _, lang in ipairs(langs) do
		vim.fn.mkdir(queries_dir .. "/" .. lang, "p")
		for _, kind in ipairs(kinds) do
			local url = base .. "/" .. lang .. "/" .. kind .. ".scm"
			local out = queries_dir .. "/" .. lang .. "/" .. kind .. ".scm"
			vim.system(
				{ "curl", "-fsS", "--remove-on-error", "-o", out, url },
				{ text = true },
				vim.schedule_wrap(function(res)
					if res.code == 0 then
						stats.ok = stats.ok + 1
					else
						stats.failed = stats.failed + 1
					end
					pending = pending - 1
					if pending == 0 then
						vim.notify(string.format(
							"UpdateQueries done: %d updated, %d not fetched (missing upstream or transfer error)",
							stats.ok, stats.failed
						))
					end
				end)
			)
		end
	end
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
				if vim.b.keep_term then
					return
				end
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
		{
			"BufWritePost",
			function()
				pcall(vim.cmd.helptags, vim.fn.stdpath("config") .. "/doc")
			end,
			{ pattern = vim.fn.stdpath("config") .. "/doc/*.txt" },
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
		{ "RunFile", run_file, {} },
		{ "Lazygit", lazygit, {} },
		{ "Run", run_async, { nargs = "+" } },
		{ "UpdateQueries", update_queries, { nargs = "*", complete = "dir" } },
		{ "Cht", cht, { nargs = "+" } },
		{ "Docs", docs, { nargs = "?", bang = true } },
	},
}
