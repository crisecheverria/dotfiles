local function default_base_branch()
	local origin_head = vim.system({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }, { text = true }):wait()
	if origin_head.code == 0 then
		local ref = vim.trim(origin_head.stdout)
		if ref ~= "" then
			return ref:gsub("^origin/", "")
		end
	end
	for _, name in ipairs({ "main", "master", "trunk" }) do
		if vim.system({ "git", "rev-parse", "--verify", "--quiet", name }, { text = true }):wait().code == 0 then
			return name
		end
	end
	return "main"
end

local function git_output(cmd, title, filetype)
	local result = vim.system(cmd, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return
	end

	local lines = vim.split(result.stdout, "\n", { trimempty = true })
	-- Wipe existing buffer with this name if it exists
	local existing = vim.fn.bufnr(title)
	if existing ~= -1 then
		vim.api.nvim_buf_delete(existing, { force = true })
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_set_name(buf, title)
	if filetype then
		vim.bo[buf].filetype = filetype
	end

	vim.cmd("split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, silent = true })
end

-- Git signs: show added/changed/deleted lines in the sign column
local ns = vim.api.nvim_create_namespace("git_signs")
local timers = {}

vim.api.nvim_set_hl(0, "GitSignAdd", { link = "Added" })
vim.api.nvim_set_hl(0, "GitSignChange", { link = "Changed" })
vim.api.nvim_set_hl(0, "GitSignDelete", { link = "Removed" })

local function update_signs(buf)
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
		return
	end

	local file = vim.api.nvim_buf_get_name(buf)
	if file == "" then
		return
	end

	local dir = vim.fn.fnamemodify(file, ":h")

	vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true, cwd = dir }, function(top)
		if top.code ~= 0 then
			return
		end
		local root = top.stdout:gsub("\n$", "")
		local rel = file:sub(#root + 2)

		vim.system({ "git", "show", "HEAD:" .. rel }, { text = true, cwd = root }, function(result)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end

				vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

				local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				local buf_text = table.concat(buf_lines, "\n") .. "\n"

				if result.code ~= 0 then
					-- New file not in git: mark all lines as added
					for i = 0, #buf_lines - 1 do
						vim.api.nvim_buf_set_extmark(buf, ns, i, 0, {
							sign_text = "▎",
							sign_hl_group = "GitSignAdd",
						})
					end
					return
				end

				local hunks = vim.text.diff(result.stdout, buf_text, { result_type = "indices" })
				if not hunks then
					return
				end

				for _, hunk in ipairs(hunks) do
					local _, count_a, start_b, count_b = unpack(hunk)

					if count_a == 0 then
						-- Added lines
						for i = start_b, start_b + count_b - 1 do
							vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
								sign_text = "▎",
								sign_hl_group = "GitSignAdd",
							})
						end
					elseif count_b == 0 then
						-- Deleted lines: mark the line above the deletion
						local line = math.max(0, start_b - 1)
						vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
							sign_text = "▎",
							sign_hl_group = "GitSignDelete",
						})
					else
						-- Changed lines
						for i = start_b, start_b + count_b - 1 do
							vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
								sign_text = "▎",
								sign_hl_group = "GitSignChange",
							})
						end
					end
				end
			end)
		end)
	end)
end

local function schedule_update(buf)
	if timers[buf] then
		timers[buf]:stop()
	end
	timers[buf] = vim.uv.new_timer()
	timers[buf]:start(
		200,
		0,
		vim.schedule_wrap(function()
			timers[buf] = nil
			update_signs(buf)
		end)
	)
end

local function get_git_file_info()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return
	end
	local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if result.code ~= 0 then
		return
	end
	local root = result.stdout:gsub("\n$", "")
	local rel = file:sub(#root + 2)
	return root, rel
end

local function patch_from_diff_buffer(line1, line2)
	local all = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Build file sections: each starts with "diff --git"
	local files = {}
	local cur_file, cur_hunk
	for i, line in ipairs(all) do
		if line:match("^diff %-%-git") then
			if cur_hunk then
				cur_hunk.end_idx = i - 1
			end
			cur_file = { header_start = i, hunks = {} }
			cur_hunk = nil
			table.insert(files, cur_file)
		elseif line:match("^@@") and cur_file then
			if cur_hunk then
				cur_hunk.end_idx = i - 1
			end
			if not cur_file.header_end then
				cur_file.header_end = i - 1
			end
			cur_hunk = { start_idx = i }
			table.insert(cur_file.hunks, cur_hunk)
		end
	end
	if cur_hunk then
		cur_hunk.end_idx = #all
	end

	-- Collect file headers + hunks overlapping with [line1, line2]
	local parts = {}
	local count = 0
	for _, file in ipairs(files) do
		local selected = {}
		for _, hunk in ipairs(file.hunks) do
			if hunk.start_idx <= line2 and hunk.end_idx >= line1 then
				table.insert(selected, hunk)
			end
		end
		if #selected > 0 then
			for i = file.header_start, file.header_end do
				table.insert(parts, all[i])
			end
			for _, hunk in ipairs(selected) do
				for i = hunk.start_idx, hunk.end_idx do
					table.insert(parts, all[i])
				end
				count = count + 1
			end
		end
	end

	if count == 0 then
		return
	end
	return table.concat(parts, "\n") .. "\n", count
end

local function filter_diff(diff_text, start_line, end_line)
	local diff_lines = vim.split(diff_text, "\n")
	local header = {}
	local hunk_list = {}

	-- Parse into header + hunks
	for i, line in ipairs(diff_lines) do
		if line:match("^@@") then
			if #header == 0 and #hunk_list == 0 then
				for j = 1, i - 1 do
					table.insert(header, diff_lines[j])
				end
			end
			if #hunk_list > 0 then
				hunk_list[#hunk_list].end_idx = i - 1
			end
			local os, oc, ns, nc = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
			table.insert(hunk_list, {
				start_idx = i + 1,
				old_start = tonumber(os),
				old_count = tonumber(oc ~= "" and oc or "1"),
				new_start = tonumber(ns),
				new_count = tonumber(nc ~= "" and nc or "1"),
			})
		end
	end
	if #hunk_list == 0 then
		return
	end
	hunk_list[#hunk_list].end_idx = #diff_lines

	-- Filter each hunk to only include lines within the selection
	local result_hunks = {}
	for _, hunk in ipairs(hunk_list) do
		local new_line = hunk.new_start
		local filtered = {}
		local has_changes = false
		local old_cnt = 0
		local new_cnt = 0

		for i = hunk.start_idx, hunk.end_idx do
			local line = diff_lines[i]
			local prefix = line:sub(1, 1)

			if prefix == "+" then
				if new_line >= start_line and new_line <= end_line then
					table.insert(filtered, line)
					new_cnt = new_cnt + 1
					has_changes = true
				else
					-- Keep as context (line exists in working tree, we're not discarding it)
					table.insert(filtered, " " .. line:sub(2))
					old_cnt = old_cnt + 1
					new_cnt = new_cnt + 1
				end
				new_line = new_line + 1
			elseif prefix == "-" then
				if new_line >= start_line and new_line <= end_line then
					table.insert(filtered, line)
					old_cnt = old_cnt + 1
					has_changes = true
				end
				-- Outside selection: drop entirely (line doesn't exist in working tree)
			elseif prefix == " " then
				table.insert(filtered, line)
				old_cnt = old_cnt + 1
				new_cnt = new_cnt + 1
				new_line = new_line + 1
			elseif prefix == "\\" then
				if #filtered > 0 then
					table.insert(filtered, line)
				end
			end
		end

		if has_changes then
			table.insert(result_hunks, {
				header = string.format(
					"@@ -%d,%d +%d,%d @@",
					hunk.old_start, old_cnt, hunk.new_start, new_cnt
				),
				lines = filtered,
			})
		end
	end

	if #result_hunks == 0 then
		return
	end

	local parts = {}
	for _, h in ipairs(header) do
		table.insert(parts, h)
	end
	for _, h in ipairs(result_hunks) do
		table.insert(parts, h.header)
		for _, l in ipairs(h.lines) do
			table.insert(parts, l)
		end
	end
	return table.concat(parts, "\n") .. "\n", #result_hunks
end

return {
	autocmds = {
		{
			{ "BufReadPost", "BufWritePost" },
			function(ev)
				update_signs(ev.buf)
			end,
		},
		{
			{ "TextChanged", "TextChangedI" },
			function(ev)
				schedule_update(ev.buf)
			end,
		},
		{
			"BufUnload",
			function(ev)
				if timers[ev.buf] then
					timers[ev.buf]:stop()
					timers[ev.buf] = nil
				end
			end,
		},
	},
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
				local extra_args = {}
				if args.args ~= "" then
					for arg in args.args:gmatch("%S+") do
						table.insert(extra_args, arg)
					end
				end

				local is_cached = vim.tbl_contains(extra_args, "--cached")
					or vim.tbl_contains(extra_args, "--staged")

				local cmd = { "git", "diff", "--name-only" }
				vim.list_extend(cmd, extra_args)
				local result = vim.system(cmd, { text = true }):wait()
				if result.code ~= 0 then
					return vim.notify(result.stderr, vim.log.levels.ERROR)
				end
				local files = vim.split(result.stdout, "\n", { trimempty = true })
				if #files == 0 then
					return vim.notify("No changes", vim.log.levels.INFO)
				end

				local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]

				vim.cmd("tabnew")
				local tab = vim.api.nvim_get_current_tabpage()

				local state = { files = files, index = 0, bufs = {} }

				-- Diff area (top, two vertical splits)
				vim.cmd("vsplit")
				local right_win = vim.api.nvim_get_current_win()
				vim.cmd("wincmd h")
				local left_win = vim.api.nvim_get_current_win()
				state.left_diff_win = left_win
				state.right_diff_win = right_win

				-- File panel (bottom)
				local panel_buf = vim.api.nvim_create_buf(false, true)
				local display = {}
				for i, f in ipairs(files) do
					display[i] = "  " .. f
				end
				vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, display)
				vim.bo[panel_buf].modifiable = false
				vim.bo[panel_buf].buftype = "nofile"
				pcall(vim.api.nvim_buf_set_name, panel_buf, "diff:files")
				vim.cmd("botright split")
				local panel_win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(panel_win, panel_buf)
				local panel_height = math.min(#files + 1, 15)
				vim.api.nvim_win_set_height(panel_win, panel_height)
				vim.wo[panel_win].number = false
				vim.wo[panel_win].relativenumber = false
				vim.wo[panel_win].winfixheight = true
				vim.wo[panel_win].wrap = false
				vim.wo[panel_win].cursorline = true
				state.panel_buf = panel_buf
				state.panel_win = panel_win

				local function highlight_panel(idx)
					vim.bo[panel_buf].modifiable = true
					local lines = {}
					for i, f in ipairs(state.files) do
						lines[i] = (i == idx and "> " or "  ") .. f
					end
					vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, lines)
					vim.bo[panel_buf].modifiable = false
					if vim.api.nvim_win_is_valid(state.panel_win) then
						vim.api.nvim_win_set_cursor(state.panel_win, { idx, 0 })
					end
				end

				local function load_file(idx)
					if idx < 1 or idx > #state.files then
						return
					end
					state.index = idx
					highlight_panel(idx)

					local rel = state.files[idx]
					local abs = root .. "/" .. rel
					local ft = vim.filetype.match({ filename = rel }) or ""

					-- Turn off diff mode and clean up old buffers
					if vim.api.nvim_win_is_valid(state.left_diff_win) then
						vim.api.nvim_set_current_win(state.left_diff_win)
						vim.cmd("diffoff")
					end
					if vim.api.nvim_win_is_valid(state.right_diff_win) then
						vim.api.nvim_set_current_win(state.right_diff_win)
						vim.cmd("diffoff")
					end
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							for _, w in ipairs(vim.fn.win_findbuf(b)) do
								local scratch = vim.api.nvim_create_buf(false, true)
								vim.api.nvim_win_set_buf(w, scratch)
							end
							vim.api.nvim_buf_delete(b, { force = true })
						end
					end
					state.bufs = {}

					-- Left buffer: "before" version
					local before_cmd = is_cached
						and { "git", "show", "HEAD:" .. rel }
						or { "git", "show", ":0:" .. rel }
					local before_lines = {}
					local r = vim.system(before_cmd, { text = true, cwd = root }):wait()
					if r.code == 0 then
						before_lines = vim.split(r.stdout, "\n", { trimempty = false })
					end
					local before_buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(before_buf, 0, -1, false, before_lines)
					vim.bo[before_buf].modifiable = false
					vim.bo[before_buf].buftype = "nofile"
					vim.bo[before_buf].filetype = ft
					local before_label = is_cached and "HEAD:" or "Index:"
					pcall(vim.api.nvim_buf_set_name, before_buf, before_label .. rel)
					table.insert(state.bufs, before_buf)

					-- Right buffer: "after" version
					local after_lines = {}
					if is_cached then
						local ar = vim.system({ "git", "show", ":0:" .. rel }, { text = true, cwd = root }):wait()
						if ar.code == 0 then
							after_lines = vim.split(ar.stdout, "\n", { trimempty = false })
						end
					else
						local f = io.open(abs, "r")
						if f then
							local content = f:read("*a")
							f:close()
							after_lines = vim.split(content, "\n", { trimempty = false })
						end
					end
					local after_buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(after_buf, 0, -1, false, after_lines)
					vim.bo[after_buf].modifiable = false
					vim.bo[after_buf].buftype = "nofile"
					vim.bo[after_buf].filetype = ft
					local after_label = is_cached and "Staged:" or "Working:"
					pcall(vim.api.nvim_buf_set_name, after_buf, after_label .. rel)
					table.insert(state.bufs, after_buf)

					-- Set buffers in diff windows
					if vim.api.nvim_win_is_valid(state.left_diff_win) then
						vim.api.nvim_win_set_buf(state.left_diff_win, before_buf)
						vim.api.nvim_set_current_win(state.left_diff_win)
						vim.cmd("diffthis")
					end
					if vim.api.nvim_win_is_valid(state.right_diff_win) then
						vim.api.nvim_win_set_buf(state.right_diff_win, after_buf)
						vim.api.nvim_set_current_win(state.right_diff_win)
						vim.cmd("diffthis")
					end
				end

				local function close_diff()
					vim.cmd("diffoff!")
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							vim.api.nvim_buf_delete(b, { force = true })
						end
					end
					if vim.api.nvim_buf_is_valid(panel_buf) then
						vim.api.nvim_buf_delete(panel_buf, { force = true })
					end
					if vim.api.nvim_tabpage_is_valid(tab) then
						local tabs = vim.api.nvim_list_tabpages()
						if #tabs > 1 then
							vim.cmd("tabclose")
						end
					end
				end

				local function next_file()
					local next = state.index + 1
					if next > #state.files then
						next = 1
					end
					load_file(next)
				end

				local function prev_file()
					local prev = state.index - 1
					if prev < 1 then
						prev = #state.files
					end
					load_file(prev)
				end

				local function set_keys(buf)
					local opts = { buffer = buf, silent = true }
					vim.keymap.set("n", "<Tab>", next_file, opts)
					vim.keymap.set("n", "<S-Tab>", prev_file, opts)
					vim.keymap.set("n", "q", close_diff, opts)
				end

				set_keys(panel_buf)

				vim.keymap.set("n", "<CR>", function()
					local line = vim.api.nvim_win_get_cursor(state.panel_win)[1]
					load_file(line)
				end, { buffer = panel_buf, silent = true })

				local orig_load = load_file
				load_file = function(idx)
					orig_load(idx)
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							set_keys(b)
						end
					end
				end

				load_file(1)
			end,
			{ nargs = "?", desc = "Git diff with file panel and side-by-side view" },
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
				local result = vim.system({ "git", "blame", "--porcelain", file }, { text = true }):wait()
				if result.code ~= 0 then
					vim.notify(result.stderr, vim.log.levels.ERROR)
					return
				end

				local source_win = vim.api.nvim_get_current_win()
				local cursor = vim.api.nvim_win_get_cursor(source_win)

				-- Parse porcelain blame into compact annotations
				local annotations = {}
				local commits = {} -- cache commit info since porcelain only describes each commit once
				local current_hash
				local max_width = 0
				for line in result.stdout:gmatch("[^\n]+") do
					local hash = line:match("^(%x+) %d+ %d+")
					if hash then
						current_hash = hash
						if not commits[hash] then
							commits[hash] = {}
						end
					elseif line:match("^author ") then
						commits[current_hash].author = line:sub(8)
					elseif line:match("^author%-time ") then
						commits[current_hash].date = os.date("%Y-%m-%d", tonumber(line:sub(13)))
					elseif line:match("^\t") then
						local info = commits[current_hash]
						local text = string.format("%s %s %s", current_hash:sub(1, 7), info.author, info.date)
						if #text > max_width then
							max_width = #text
						end
						table.insert(annotations, text)
					end
				end

				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, annotations)
				vim.bo[buf].modifiable = false
				vim.api.nvim_buf_set_name(buf, "git:blame")

				-- Apply highlights per segment: hash, author, date
				local blame_ns = vim.api.nvim_create_namespace("git_blame")
				for i, text in ipairs(annotations) do
					local hash_end = 7
					local date_start = #text - 10
					vim.api.nvim_buf_set_extmark(buf, blame_ns, i - 1, 0, {
						end_col = hash_end,
						hl_group = "Function",
					})
					vim.api.nvim_buf_set_extmark(buf, blame_ns, i - 1, hash_end + 1, {
						end_col = date_start - 1,
						hl_group = "Title",
					})
					vim.api.nvim_buf_set_extmark(buf, blame_ns, i - 1, date_start, {
						end_col = #text,
						hl_group = "Comment",
					})
				end

				vim.cmd("leftabove " .. math.min(max_width + 2, 60) .. "vsplit")
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
				vim.cmd("syncbind")

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
		{
			"Gdiffbranch",
			function(args)
				local base = args.args ~= "" and args.args or default_base_branch()
				git_output({ "git", "diff", base .. "...HEAD" }, "git:diff:" .. base, "diff")
			end,
			{ nargs = "?", desc = "Git diff current branch vs base (default: repo default branch)" },
		},
		{
			"Greview",
			function(args)
				local base = args.args ~= "" and args.args or default_base_branch()
				local result = vim.system({ "git", "diff", "--name-only", base .. "...HEAD" }, { text = true }):wait()
				if result.code ~= 0 then
					vim.notify(result.stderr, vim.log.levels.ERROR)
					return
				end
				local files = vim.split(result.stdout, "\n", { trimempty = true })
				if #files == 0 then
					vim.notify("No changes vs " .. base, vim.log.levels.INFO)
					return
				end

				local function short_path(path)
					local parts = vim.split(path, "/")
					if #parts <= 3 then
						return path
					end
					return table.concat({ parts[#parts - 2], parts[#parts - 1], parts[#parts] }, "/")
				end

				local state = { files = files, base = base, index = 0, bufs = {} }
				local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]

				-- Create a dedicated tab so we don't disturb existing layout
				vim.cmd("tabnew")
				local tab = vim.api.nvim_get_current_tabpage()

				-- Diff area (top, two vertical splits)
				vim.cmd("vsplit")
				local right_win = vim.api.nvim_get_current_win()
				vim.cmd("wincmd h")
				local left_diff_win = vim.api.nvim_get_current_win()
				state.left_diff_win = left_diff_win
				state.right_diff_win = right_win

				-- File panel (bottom, horizontal)
				local panel_buf = vim.api.nvim_create_buf(false, true)
				local display = {}
				for i, f in ipairs(files) do
					display[i] = "  " .. f
				end
				vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, display)
				vim.bo[panel_buf].modifiable = false
				vim.bo[panel_buf].buftype = "nofile"
				vim.api.nvim_buf_set_name(panel_buf, "review:" .. base)
				vim.cmd("botright split")
				local panel_win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(panel_win, panel_buf)
				local panel_height = math.min(#files + 1, 15)
				vim.api.nvim_win_set_height(panel_win, panel_height)
				vim.wo[panel_win].number = false
				vim.wo[panel_win].relativenumber = false
				vim.wo[panel_win].winfixheight = true
				vim.wo[panel_win].wrap = false
				vim.wo[panel_win].cursorline = true
				state.panel_buf = panel_buf
				state.panel_win = panel_win

				local function highlight_panel(idx)
					vim.bo[panel_buf].modifiable = true
					local lines = {}
					for i, f in ipairs(state.files) do
						lines[i] = (i == idx and "> " or "  ") .. f
					end
					vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, lines)
					vim.bo[panel_buf].modifiable = false
					if vim.api.nvim_win_is_valid(state.panel_win) then
						vim.api.nvim_win_set_cursor(state.panel_win, { idx, 0 })
					end
				end

				local function load_file(idx)
					if idx < 1 or idx > #state.files then
						return
					end
					state.index = idx
					highlight_panel(idx)

					local rel = state.files[idx]
					local abs = root .. "/" .. rel
					local ft = vim.filetype.match({ filename = rel }) or ""

					-- Turn off diff mode and clean up old diff buffers
					if vim.api.nvim_win_is_valid(state.left_diff_win) then
						vim.api.nvim_set_current_win(state.left_diff_win)
						vim.cmd("diffoff")
					end
					if vim.api.nvim_win_is_valid(state.right_diff_win) then
						vim.api.nvim_set_current_win(state.right_diff_win)
						vim.cmd("diffoff")
					end
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							-- Unload without closing windows by replacing first
							for _, w in ipairs(vim.fn.win_findbuf(b)) do
								local scratch = vim.api.nvim_create_buf(false, true)
								vim.api.nvim_win_set_buf(w, scratch)
							end
							vim.api.nvim_buf_delete(b, { force = true })
						end
					end
					state.bufs = {}

					-- Left: base version
					local base_result = vim.system({ "git", "show", base .. ":" .. rel }, { text = true }):wait()
					local base_lines = {}
					if base_result.code == 0 then
						base_lines = vim.split(base_result.stdout, "\n", { trimempty = false })
					end
					local base_buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(base_buf, 0, -1, false, base_lines)
					vim.bo[base_buf].modifiable = false
					vim.bo[base_buf].buftype = "nofile"
					vim.bo[base_buf].filetype = ft
					pcall(vim.api.nvim_buf_set_name, base_buf, base .. ":" .. rel)
					table.insert(state.bufs, base_buf)

					-- Right: current version
					local head_lines = {}
					local f = io.open(abs, "r")
					if f then
						local content = f:read("*a")
						f:close()
						head_lines = vim.split(content, "\n", { trimempty = false })
					end
					local head_buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, head_lines)
					vim.bo[head_buf].modifiable = false
					vim.bo[head_buf].buftype = "nofile"
					vim.bo[head_buf].filetype = ft
					pcall(vim.api.nvim_buf_set_name, head_buf, "HEAD:" .. rel)
					table.insert(state.bufs, head_buf)

					-- Set buffers in diff windows
					if vim.api.nvim_win_is_valid(state.left_diff_win) then
						vim.api.nvim_win_set_buf(state.left_diff_win, base_buf)
						vim.api.nvim_set_current_win(state.left_diff_win)
						vim.cmd("diffthis")
					end
					if vim.api.nvim_win_is_valid(state.right_diff_win) then
						vim.api.nvim_win_set_buf(state.right_diff_win, head_buf)
						vim.api.nvim_set_current_win(state.right_diff_win)
						vim.cmd("diffthis")
					end
				end

				local function close_review()
					vim.cmd("diffoff!")
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							vim.api.nvim_buf_delete(b, { force = true })
						end
					end
					if vim.api.nvim_buf_is_valid(panel_buf) then
						vim.api.nvim_buf_delete(panel_buf, { force = true })
					end
					-- Close the review tab if it still exists
					if vim.api.nvim_tabpage_is_valid(tab) then
						local tabs = vim.api.nvim_list_tabpages()
						if #tabs > 1 then
							vim.cmd("tabclose")
						end
					end
				end

				local function next_file()
					local next = state.index + 1
					if next > #state.files then
						next = 1
					end
					load_file(next)
				end

				local function prev_file()
					local prev = state.index - 1
					if prev < 1 then
						prev = #state.files
					end
					load_file(prev)
				end

				-- Keymaps for all buffers in the review tab
				local function set_review_keys(buf)
					local opts = { buffer = buf, silent = true }
					vim.keymap.set("n", "<Tab>", next_file, opts)
					vim.keymap.set("n", "<S-Tab>", prev_file, opts)
					vim.keymap.set("n", "q", close_review, opts)
					vim.keymap.set("n", "gf", function()
						if state.index < 1 or state.index > #state.files then
							return
						end
						local abs = root .. "/" .. state.files[state.index]
						local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
						close_review()
						vim.cmd("edit " .. vim.fn.fnameescape(abs))
						pcall(vim.api.nvim_win_set_cursor, 0, { cursor_line, 0 })
					end, opts)
				end

				set_review_keys(panel_buf)

				-- Enter on file panel jumps to that file
				vim.keymap.set("n", "<CR>", function()
					local line = vim.api.nvim_win_get_cursor(state.panel_win)[1]
					load_file(line)
				end, { buffer = panel_buf, silent = true })

				-- Also set keys on diff buffers when they load
				local orig_load = load_file
				load_file = function(idx)
					orig_load(idx)
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							set_review_keys(b)
						end
					end
				end

				-- Load first file
				load_file(1)
			end,
			{ nargs = "?", desc = "Review PR: file panel + side-by-side diff" },
		},
		{
			"Ghistory",
			function(args)
				local file_only = args.args == "%"

				local root_result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
				if root_result.code ~= 0 then
					return vim.notify("Not in a git repo", vim.log.levels.ERROR)
				end
				local root = root_result.stdout:gsub("\n$", "")

				local current_file_rel
				if file_only then
					local file = vim.api.nvim_buf_get_name(0)
					if file == "" then
						return vim.notify("No file open", vim.log.levels.ERROR)
					end
					current_file_rel = file:sub(#root + 2)
				end

				-- Get commits
				local log_cmd = { "git", "log", "--pretty=format:%h\t%ad\t%an\t%s", "--date=short", "-50" }
				if file_only then
					table.insert(log_cmd, "--follow")
					table.insert(log_cmd, "--")
					table.insert(log_cmd, current_file_rel)
				end

				local result = vim.system(log_cmd, { text = true, cwd = root }):wait()
				if result.code ~= 0 then
					return vim.notify(result.stderr, vim.log.levels.ERROR)
				end

				local log_lines = vim.split(result.stdout, "\n", { trimempty = true })
				if #log_lines == 0 then
					return vim.notify("No commits found", vim.log.levels.INFO)
				end

				-- Parse commits
				local commits = {}
				local max_author = 0
				for _, line in ipairs(log_lines) do
					local hash, date, author, subject = line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)\t(.*)$")
					if hash then
						if #author > max_author then
							max_author = #author
						end
						table.insert(commits, {
							hash = hash,
							date = date,
							author = author,
							subject = subject,
						})
					end
				end

				-- Format display lines with aligned columns
				local commit_displays = {}
				for _, c in ipairs(commits) do
					table.insert(commit_displays, string.format(
						"%s  %s  %-" .. max_author .. "s  %s",
						c.hash, c.date, c.author, c.subject
					))
				end

				-- Create tab
				vim.cmd("tabnew")
				local tab = vim.api.nvim_get_current_tabpage()

				local state = {
					commits = commits,
					commit_index = 0,
					files = {},
					file_index = 0,
					bufs = {},
					mode = "commits",
				}

				-- Diff area (top, two vertical splits)
				vim.cmd("vsplit")
				local right_win = vim.api.nvim_get_current_win()
				vim.cmd("wincmd h")
				local left_win = vim.api.nvim_get_current_win()
				state.left_diff_win = left_win
				state.right_diff_win = right_win

				-- Panel (bottom)
				local panel_buf = vim.api.nvim_create_buf(false, true)
				pcall(vim.api.nvim_buf_set_name, panel_buf, "history:panel")
				vim.bo[panel_buf].buftype = "nofile"
				vim.cmd("botright split")
				local panel_win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(panel_win, panel_buf)
				vim.api.nvim_win_set_height(panel_win, math.min(#commits + 1, 15))
				vim.wo[panel_win].number = false
				vim.wo[panel_win].relativenumber = false
				vim.wo[panel_win].winfixheight = true
				vim.wo[panel_win].wrap = false
				vim.wo[panel_win].cursorline = true
				state.panel_buf = panel_buf
				state.panel_win = panel_win

				local panel_ns = vim.api.nvim_create_namespace("history_panel")

				local function render_panel(items, selected)
					vim.bo[panel_buf].modifiable = true
					local lines = {}
					for i, item in ipairs(items) do
						lines[i] = (i == selected and "> " or "  ") .. item
					end
					vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, lines)
					vim.api.nvim_buf_clear_namespace(panel_buf, panel_ns, 0, -1)

					local prefix = 2 -- "> " or "  "
					if state.mode == "commits" then
						for i, c in ipairs(state.commits) do
							local col = prefix
							-- hash
							vim.api.nvim_buf_set_extmark(panel_buf, panel_ns, i - 1, col, {
								end_col = col + #c.hash,
								hl_group = "Function",
							})
							col = col + #c.hash + 2
							-- date
							vim.api.nvim_buf_set_extmark(panel_buf, panel_ns, i - 1, col, {
								end_col = col + #c.date,
								hl_group = "Comment",
							})
							col = col + #c.date + 2
							-- author
							vim.api.nvim_buf_set_extmark(panel_buf, panel_ns, i - 1, col, {
								end_col = col + #c.author,
								hl_group = "Title",
							})
						end
					else
						for i, f in ipairs(items) do
							local ext = f:match("%.([^%.]+)$") or ""
							local hl = "Normal"
							if ext == "ts" or ext == "tsx" then
								hl = "Function"
							elseif ext == "js" or ext == "jsx" then
								hl = "Keyword"
							elseif ext == "css" or ext == "scss" then
								hl = "String"
							elseif ext == "json" then
								hl = "Comment"
							elseif ext == "md" then
								hl = "Title"
							end
							local dir_end = f:find("/[^/]*$")
							if dir_end then
								vim.api.nvim_buf_set_extmark(panel_buf, panel_ns, i - 1, prefix, {
									end_col = prefix + dir_end,
									hl_group = "Comment",
								})
								vim.api.nvim_buf_set_extmark(panel_buf, panel_ns, i - 1, prefix + dir_end, {
									end_col = prefix + #f,
									hl_group = hl,
								})
							else
								vim.api.nvim_buf_set_extmark(panel_buf, panel_ns, i - 1, prefix, {
									end_col = prefix + #f,
									hl_group = hl,
								})
							end
						end
					end

					vim.bo[panel_buf].modifiable = false
					if vim.api.nvim_win_is_valid(state.panel_win) and selected > 0 then
						vim.api.nvim_win_set_cursor(state.panel_win, { selected, 0 })
					end
				end

				local function clear_diff()
					if vim.api.nvim_win_is_valid(state.left_diff_win) then
						vim.api.nvim_set_current_win(state.left_diff_win)
						vim.cmd("diffoff")
					end
					if vim.api.nvim_win_is_valid(state.right_diff_win) then
						vim.api.nvim_set_current_win(state.right_diff_win)
						vim.cmd("diffoff")
					end
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							for _, w in ipairs(vim.fn.win_findbuf(b)) do
								local scratch = vim.api.nvim_create_buf(false, true)
								vim.api.nvim_win_set_buf(w, scratch)
							end
							vim.api.nvim_buf_delete(b, { force = true })
						end
					end
					state.bufs = {}
				end

				local function show_diff(hash, rel)
					clear_diff()

					local ft = vim.filetype.match({ filename = rel }) or ""

					-- Before: parent commit version
					local before_lines = {}
					local r = vim.system(
						{ "git", "show", hash .. "~1:" .. rel },
						{ text = true, cwd = root }
					):wait()
					if r.code == 0 then
						before_lines = vim.split(r.stdout, "\n", { trimempty = false })
					end
					local before_buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(before_buf, 0, -1, false, before_lines)
					vim.bo[before_buf].modifiable = false
					vim.bo[before_buf].buftype = "nofile"
					vim.bo[before_buf].filetype = ft
					pcall(vim.api.nvim_buf_set_name, before_buf, hash .. "~1:" .. rel)
					table.insert(state.bufs, before_buf)

					-- After: this commit version
					local after_lines = {}
					local ar = vim.system(
						{ "git", "show", hash .. ":" .. rel },
						{ text = true, cwd = root }
					):wait()
					if ar.code == 0 then
						after_lines = vim.split(ar.stdout, "\n", { trimempty = false })
					end
					local after_buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(after_buf, 0, -1, false, after_lines)
					vim.bo[after_buf].modifiable = false
					vim.bo[after_buf].buftype = "nofile"
					vim.bo[after_buf].filetype = ft
					pcall(vim.api.nvim_buf_set_name, after_buf, hash .. ":" .. rel)
					table.insert(state.bufs, after_buf)

					if vim.api.nvim_win_is_valid(state.left_diff_win) then
						vim.api.nvim_win_set_buf(state.left_diff_win, before_buf)
						vim.api.nvim_set_current_win(state.left_diff_win)
						vim.cmd("diffthis")
					end
					if vim.api.nvim_win_is_valid(state.right_diff_win) then
						vim.api.nvim_win_set_buf(state.right_diff_win, after_buf)
						vim.api.nvim_set_current_win(state.right_diff_win)
						vim.cmd("diffthis")
					end
				end

				local function close_history()
					vim.cmd("diffoff!")
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							vim.api.nvim_buf_delete(b, { force = true })
						end
					end
					if vim.api.nvim_buf_is_valid(panel_buf) then
						vim.api.nvim_buf_delete(panel_buf, { force = true })
					end
					if vim.api.nvim_tabpage_is_valid(tab) then
						local tabs = vim.api.nvim_list_tabpages()
						if #tabs > 1 then
							vim.cmd("tabclose")
						end
					end
				end

				local set_keys

				local function show_commits_panel()
					state.mode = "commits"
					state.commit_index = math.max(state.commit_index, 1)
					render_panel(commit_displays, state.commit_index)
				end

				local function load_file_in_commit(file_idx)
					if file_idx < 1 or file_idx > #state.files then
						return
					end
					state.file_index = file_idx
					render_panel(state.files, file_idx)
					show_diff(state.commits[state.commit_index].hash, state.files[file_idx])
					for _, b in ipairs(state.bufs) do
						if vim.api.nvim_buf_is_valid(b) then
							set_keys(b)
						end
					end
				end

				local function enter_commit(commit_idx)
					if commit_idx < 1 or commit_idx > #state.commits then
						return
					end
					state.commit_index = commit_idx
					local hash = state.commits[commit_idx].hash

					if file_only then
						render_panel(commit_displays, commit_idx)
						show_diff(hash, current_file_rel)
						for _, b in ipairs(state.bufs) do
							if vim.api.nvim_buf_is_valid(b) then
								set_keys(b)
							end
						end
						return
					end

					-- Project mode: get files changed in this commit
					local r = vim.system(
						{ "git", "diff-tree", "--no-commit-id", "-r", "--name-only", hash },
						{ text = true, cwd = root }
					):wait()
					if r.code ~= 0 then
						return vim.notify(r.stderr, vim.log.levels.ERROR)
					end

					state.files = vim.split(r.stdout, "\n", { trimempty = true })
					if #state.files == 0 then
						return vim.notify("No files in commit")
					end

					state.mode = "files"
					state.file_index = 1
					load_file_in_commit(1)
				end

				local function next_item()
					if file_only then
						local next = state.commit_index + 1
						if next > #state.commits then
							next = 1
						end
						enter_commit(next)
					elseif state.mode == "files" then
						local next = state.file_index + 1
						if next > #state.files then
							next = 1
						end
						load_file_in_commit(next)
					elseif state.mode == "commits" then
						local next = state.commit_index + 1
						if next > #state.commits then
							next = 1
						end
						enter_commit(next)
					end
				end

				local function prev_item()
					if file_only then
						local prev = state.commit_index - 1
						if prev < 1 then
							prev = #state.commits
						end
						enter_commit(prev)
					elseif state.mode == "files" then
						local prev = state.file_index - 1
						if prev < 1 then
							prev = #state.files
						end
						load_file_in_commit(prev)
					elseif state.mode == "commits" then
						local prev = state.commit_index - 1
						if prev < 1 then
							prev = #state.commits
						end
						enter_commit(prev)
					end
				end

				local function go_back()
					if state.mode == "files" and not file_only then
						clear_diff()
						show_commits_panel()
						if vim.api.nvim_win_is_valid(state.panel_win) then
							vim.api.nvim_set_current_win(state.panel_win)
						end
					end
				end

				set_keys = function(buf)
					local opts = { buffer = buf, silent = true }
					vim.keymap.set("n", "<Tab>", next_item, opts)
					vim.keymap.set("n", "<S-Tab>", prev_item, opts)
					vim.keymap.set("n", "q", close_history, opts)
					vim.keymap.set("n", "<Backspace>", go_back, opts)
				end

				set_keys(panel_buf)

				vim.keymap.set("n", "<CR>", function()
					local line = vim.api.nvim_win_get_cursor(state.panel_win)[1]
					if state.mode == "commits" then
						enter_commit(line)
					else
						load_file_in_commit(line)
					end
				end, { buffer = panel_buf, silent = true })

				-- Show commits and auto-load first in file mode
				show_commits_panel()
				if file_only and #commits > 0 then
					enter_commit(1)
				end
			end,
			{ nargs = "?", desc = "Git history (% for current file)" },
		},
		{
			"Gstage",
			function(opts)
				local root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
				if root.code ~= 0 then
					return vim.notify("Not in a git repo", vim.log.levels.ERROR)
				end
				local cwd = root.stdout:gsub("\n$", "")

				local patch, count
				if vim.bo.filetype == "diff" then
					-- Staging from Gdiff buffer
					patch, count = patch_from_diff_buffer(opts.line1, opts.line2)
				else
					-- Staging from file buffer
					vim.cmd("silent write")
					local _, rel = get_git_file_info()
					if not rel then
						return vim.notify("Not a git file", vim.log.levels.ERROR)
					end
					local diff = vim.system({ "git", "diff", "--", rel }, { text = true, cwd = cwd }):wait()
					if diff.stdout == "" then
						return vim.notify("No unstaged changes")
					end
					patch, count = filter_diff(diff.stdout, opts.line1, opts.line2)
				end

				if not patch then
					return vim.notify("No hunks in selection")
				end

				local result = vim.system(
					{ "git", "apply", "--cached", "-" },
					{ text = true, cwd = cwd, stdin = patch }
				):wait()
				if result.code == 0 then
					vim.notify(count .. " hunk(s) staged")
					for _, b in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_loaded(b) then
							update_signs(b)
						end
					end
				else
					vim.notify("Stage failed: " .. result.stderr, vim.log.levels.ERROR)
				end
			end,
			{ range = true, desc = "Stage selected hunks" },
		},
		{
			"Gdiscard",
			function(opts)
				vim.cmd("silent write")
				local root, rel = get_git_file_info()
				if not root then
					return vim.notify("Not in a git repo", vim.log.levels.ERROR)
				end

				local diff = vim.system({ "git", "diff", "--", rel }, { text = true, cwd = root }):wait()
				if diff.stdout == "" then
					return vim.notify("No unstaged changes")
				end

				local patch, count = filter_diff(diff.stdout, opts.line1, opts.line2)
				if not patch then
					return vim.notify("No hunks in selection")
				end

				local result = vim.system({ "git", "apply", "-R", "--recount", "-" }, { text = true, cwd = root, stdin = patch })
					 :wait()
				if result.code == 0 then
					vim.notify(count .. " hunk(s) discarded")
					vim.cmd("edit!")
				else
					vim.notify("Discard failed: " .. result.stderr, vim.log.levels.ERROR)
				end
			end,
			{ range = true, desc = "Discard selected hunks" },
		},
		{
			"Gcommit",
			function()
				-- Show staged diff as context
				local staged = vim.system({ "git", "diff", "--cached", "--stat" }, { text = true }):wait()
				if staged.code ~= 0 or staged.stdout == "" then
					return vim.notify("Nothing staged to commit", vim.log.levels.WARN)
				end

				local buf = vim.api.nvim_create_buf(false, true)
				local comment_lines = {}
				table.insert(comment_lines, "")
				table.insert(comment_lines, "# Staged changes:")
				for _, line in ipairs(vim.split(staged.stdout, "\n", { trimempty = true })) do
					table.insert(comment_lines, "# " .. line)
				end
				table.insert(comment_lines, "#")
				table.insert(comment_lines, "# Write your commit message above. Save and close to commit.")
				table.insert(comment_lines, "# Leave empty or delete all lines to abort.")
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, comment_lines)
				vim.api.nvim_win_set_buf(0, buf)
				vim.api.nvim_win_set_cursor(0, { 1, 0 })
				vim.bo[buf].filetype = "gitcommit"
				vim.bo[buf].buftype = "acwrite"
				vim.api.nvim_buf_set_name(buf, "COMMIT_MSG")

				vim.api.nvim_create_autocmd("BufWriteCmd", {
					buffer = buf,
					once = true,
					callback = function()
						local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
						local msg_lines = {}
						for _, l in ipairs(lines) do
							if not l:match("^#") then
								table.insert(msg_lines, l)
							end
						end
						-- Trim trailing empty lines
						while #msg_lines > 0 and msg_lines[#msg_lines] == "" do
							table.remove(msg_lines)
						end
						local msg = table.concat(msg_lines, "\n")
						if msg == "" then
							vim.api.nvim_buf_delete(buf, { force = true })
							return vim.notify("Commit aborted")
						end
						local result = vim.system({ "git", "commit", "-m", msg }, { text = true }):wait()
						vim.api.nvim_buf_delete(buf, { force = true })
						vim.notify(result.code == 0 and result.stdout or result.stderr)
						if result.code == 0 then
							for _, b in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_is_loaded(b) then
									update_signs(b)
								end
							end
						end
					end,
				})

				vim.keymap.set("n", "q", function()
					vim.api.nvim_buf_delete(buf, { force = true })
					vim.notify("Commit aborted")
				end, { buffer = buf, silent = true })

				vim.cmd("startinsert")
			end,
			{ desc = "Git commit" },
		},
	},
	keymaps = {
		{ { "v" }, "<leader>s",  ":Gstage<CR>",      { desc = "Stage hunk(s)" } },
		{ { "v" }, "<leader>d",  ":Gdiscard<CR>",    { desc = "Discard hunk(s)" } },
		{ { "n" }, "<leader>gc", "<cmd>Gcommit<cr>", { desc = "Git commit" } },
		{ { "n" }, "<leader>gh", "<cmd>Ghistory %<cr>", { desc = "Git file history" } },
	},
}
