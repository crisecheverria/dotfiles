local function git_output(cmd, title, filetype)
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

				local hunks = vim.diff(result.stdout, buf_text, { result_type = "indices" })
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
	timers[buf]:start(200, 0, vim.schedule_wrap(function()
		timers[buf] = nil
		update_signs(buf)
	end))
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
				local cmd = { "git", "diff" }
				if args.args ~= "" then
					table.insert(cmd, args.args)
				end
				git_output(cmd, "git:diff", "diff")
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
		{
			"Gdiffbranch",
			function(args)
				local base = args.args ~= "" and args.args or "main"
				git_output({ "git", "diff", base .. "...HEAD" }, "git:diff:" .. base, "diff")
			end,
			{ nargs = "?", desc = "Git diff current branch vs base (default: main)" },
		},
		{
			"Greview",
			function(args)
				local base = args.args ~= "" and args.args or "main"
				local result = vim.system(
					{ "git", "diff", "--name-only", base .. "...HEAD" },
					{ text = true }
				):wait()
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
					local base_result = vim.system(
						{ "git", "show", base .. ":" .. rel },
						{ text = true }
					):wait()
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
	},
	keymaps = {
		{ { "n" }, "<leader>gs", "<cmd>Gstatus<cr>", { desc = "Git status" } },
		{ { "n" }, "<leader>gd", "<cmd>Gdiff<cr>", { desc = "Git diff" } },
		{ { "n" }, "<leader>gl", "<cmd>Glog<cr>", { desc = "Git log" } },
		{ { "n" }, "<leader>gb", "<cmd>Gblame<cr>", { desc = "Git blame" } },
		{ { "n" }, "<leader>gc", "<cmd>Gcommits<cr>", { desc = "Git commits for file" } },
		{ { "n" }, "<leader>gr", "<cmd>Greview<cr>", { desc = "Review PR (changed files)" } },
	},
}
