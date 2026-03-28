local active_job = nil

local function cancel()
	if active_job then
		vim.fn.jobstop(active_job)
		active_job = nil
	end
end

local function stream_to_buf(buf, start_row, prompt, on_done)
	cancel()
	local row = start_row
	local partial = ""

	active_job = vim.fn.jobstart({ "claude", "-p", prompt }, {
		on_stdout = function(_, data)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end
				for i, chunk in ipairs(data) do
					if i == 1 then
						partial = partial .. chunk
						vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { partial })
					else
						row = row + 1
						partial = chunk
						vim.api.nvim_buf_set_lines(buf, row, row, false, { partial })
					end
				end
			end)
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				active_job = nil
				if on_done then
					on_done(code)
				end
			end)
		end,
	})
end

local function get_selection(opts)
	if opts.range == 0 then
		return nil
	end
	local ok, lines =
		pcall(vim.fn.getregion, vim.fn.getpos("'<"), vim.fn.getpos("'>"), { mode = vim.fn.visualmode() })
	if not ok or #lines == 0 then
		return nil
	end
	return table.concat(lines, "\n")
end

-- :AI [prompt] - append AI response after cursor or selection
local function ai_complete(opts)
	local selection = get_selection(opts)
	local instruction = opts.args

	local prompt
	if selection and instruction ~= "" then
		prompt = instruction .. "\n\n" .. selection
	elseif selection then
		prompt = selection
	elseif instruction ~= "" then
		prompt = instruction
	else
		vim.notify("Provide a prompt or visual selection", vim.log.levels.WARN)
		return
	end

	local buf = vim.api.nvim_get_current_buf()
	local row = opts.range > 0 and opts.line2 or vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(buf, row, row, false, { "" })
	stream_to_buf(buf, row, prompt)
end

-- :AIEdit [instruction] - replace selection with AI response
local function ai_edit(opts)
	local selection = get_selection(opts)
	if not selection then
		vim.notify("AIEdit requires a visual selection", vim.log.levels.WARN)
		return
	end

	local instruction = opts.args ~= "" and opts.args or "improve this code"
	local prompt = instruction
		.. ". Return ONLY the replacement code, no explanations, no markdown fences.\n\n"
		.. selection

	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(buf, opts.line1 - 1, opts.line2, false, { "" })
	stream_to_buf(buf, opts.line1 - 1, prompt)
end

-- Chat
local chat = { buf = nil, win = nil }

local function chat_submit()
	local buf = chat.buf
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local parts = {}
	local role = nil
	local text = {}

	for _, line in ipairs(all_lines) do
		if line:match("^>>> user$") then
			if role and #text > 0 then
				local prefix = role == "user" and "User" or "Assistant"
				local content = table.concat(text, "\n"):match("^%s*(.-)%s*$")
				if content ~= "" then
					table.insert(parts, prefix .. ": " .. content)
				end
			end
			role = "user"
			text = {}
		elseif line:match("^<<< assistant$") then
			if role and #text > 0 then
				local prefix = role == "user" and "User" or "Assistant"
				local content = table.concat(text, "\n"):match("^%s*(.-)%s*$")
				if content ~= "" then
					table.insert(parts, prefix .. ": " .. content)
				end
			end
			role = "assistant"
			text = {}
		elseif role then
			table.insert(text, line)
		end
	end

	if role and #text > 0 then
		local prefix = role == "user" and "User" or "Assistant"
		local content = table.concat(text, "\n"):match("^%s*(.-)%s*$")
		if content ~= "" then
			table.insert(parts, prefix .. ": " .. content)
		end
	end

	if #parts == 0 then
		return
	end

	local prompt = table.concat(parts, "\n\n")
	local row = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, row, row, false, { "", "<<< assistant", "" })

	stream_to_buf(buf, row + 2, prompt, function()
		if vim.api.nvim_buf_is_valid(buf) then
			local total = vim.api.nvim_buf_line_count(buf)
			vim.api.nvim_buf_set_lines(buf, total, total, false, { "", ">>> user", "" })
			if chat.win and vim.api.nvim_win_is_valid(chat.win) then
				vim.api.nvim_win_set_cursor(chat.win, { total + 3, 0 })
				vim.cmd("startinsert")
			end
		end
	end)
end

local function ensure_chat_buf()
	if chat.buf and vim.api.nvim_buf_is_valid(chat.buf) then
		return
	end

	chat.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[chat.buf].filetype = "markdown"
	vim.bo[chat.buf].bufhidden = "hide"
	vim.bo[chat.buf].swapfile = false
	pcall(vim.api.nvim_buf_set_name, chat.buf, "ai-chat")

	vim.keymap.set("n", "<CR>", chat_submit, { buffer = chat.buf, desc = "Submit to Claude" })
	vim.keymap.set("n", "q", function()
		if chat.win and vim.api.nvim_win_is_valid(chat.win) then
			vim.api.nvim_win_close(chat.win, false)
			chat.win = nil
		end
	end, { buffer = chat.buf, desc = "Close chat" })
end

local function ensure_chat_win()
	if chat.win and vim.api.nvim_win_is_valid(chat.win) then
		vim.api.nvim_set_current_win(chat.win)
		return
	end

	vim.cmd("botright 20split")
	chat.win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(chat.win, chat.buf)
end

-- :AIChat [prompt] - open chat split, optionally with selection + prompt
local function ai_chat(opts)
	local selection = get_selection(opts)
	local instruction = opts.args

	ensure_chat_buf()

	local lines = { ">>> user", "" }
	local pos = 2
	if selection then
		table.insert(lines, pos, "```")
		pos = pos + 1
		for _, l in ipairs(vim.split(selection, "\n")) do
			table.insert(lines, pos, l)
			pos = pos + 1
		end
		table.insert(lines, pos, "```")
		pos = pos + 1
		if instruction ~= "" then
			table.insert(lines, pos, "")
			pos = pos + 1
			table.insert(lines, pos, instruction)
		end
	elseif instruction ~= "" then
		table.insert(lines, pos, instruction)
	end

	local existing = vim.api.nvim_buf_get_lines(chat.buf, 0, 1, false)
	if existing[1] and existing[1] ~= "" then
		local row = vim.api.nvim_buf_line_count(chat.buf)
		vim.api.nvim_buf_set_lines(chat.buf, row, row, false, lines)
	else
		vim.api.nvim_buf_set_lines(chat.buf, 0, -1, false, lines)
	end

	ensure_chat_win()

	local total = vim.api.nvim_buf_line_count(chat.buf)
	vim.api.nvim_win_set_cursor(chat.win, { total, 0 })

	if selection or instruction ~= "" then
		chat_submit()
	else
		vim.cmd("startinsert")
	end
end

return {
	usercmds = {
		{ "AI", ai_complete, { range = true, nargs = "?" } },
		{ "AIEdit", ai_edit, { range = true, nargs = "?" } },
		{ "AIChat", ai_chat, { range = true, nargs = "?" } },
		{ "AIStop", cancel, {} },
	},
}
