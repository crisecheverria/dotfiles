local utils = require("utils")

local function cursor_gfind(str, pattern)
	return vim.tbl_map(function(position)
		return { position[1] - 1, position[2] - 1 }
	end, utils.gfind(str, pattern))
end

local function accumulate_gfind(line, patterns)
	local acc = {}
	for _, pattern in pairs(patterns) do
		acc = utils.merge_table(acc, cursor_gfind(line, pattern))
	end
	-- Convert string coordinates (1-based) to cursor coordinates (0-based)
	return acc
end

local function line_bounds(line)
	local col = vim.fn.col(".") - 1
	local lower = string.find(line, "[^%s]") - 1
	local upper = string.find(line, "[^%s]%s*$") + 1

	local idx = col
	while idx <= #line do
		local current = string.sub(line, idx, idx)
		local right = utils.v_pairs[current]
		if right then
			local ok, next = string.find(line, "%b" .. current .. right, idx)
			if not ok then
				break
			end
			idx = next + 1
		elseif current == ")" or current == "]" or current == "}" then
			upper = idx
			break
		else
			idx = idx + 1
		end
	end

	return { lower, upper }
end

local function argument(inside)
	local col = vim.fn.col(".") - 1
	local line = vim.fn.getline(".")

	local separators = cursor_gfind(line, ",")
	local brackets = accumulate_gfind(line, { "%b()", "%b[]", "%b{}" })
	local ignores = accumulate_gfind(line, { "%b''", '%b""' })

	-- Filter brackets
	local inner_most_bracket = line_bounds(line)
	brackets = vim.tbl_filter(function(bracket)
		-- Outside or on the border of a bracket
		if bracket[1] >= col or bracket[2] <= col then
			return true
		end

		local lower, upper = unpack(inner_most_bracket)
		if upper - lower > bracket[2] - bracket[1] then
			inner_most_bracket = bracket
		end
		return false
	end, brackets)

	-- Filter separators
	separators = vim.tbl_filter(function(inner)
		local merged = utils.merge_table(ignores, brackets)
		for _, outer in pairs(merged) do
			if outer[1] < inner[1] and outer[2] > inner[1] then
				return false
			end
		end
		return true
	end, separators)

	local lower, upper = unpack(inner_most_bracket)
	local start, stop = lower, upper
	for _, separator in pairs(separators) do
		local position = separator[1]
		if position > lower and position < upper then
			if position <= col then
				start = math.max(start, position)
			else
				stop = math.min(stop, position)
			end
		end
	end

	local cursor_start, cursor_stop = start, stop
	cursor_start = cursor_start + 1
	if stop == upper then
		cursor_stop = cursor_stop - 1
	end
	if inside and stop ~= upper then
		cursor_stop = cursor_stop - 1
	end
	if not inside and start ~= lower and stop == upper then
		cursor_start = cursor_start - 1
	end

	local set_cursor = function(col)
		vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), col })
	end

	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" then
		vim.cmd("normal! \27")
	end
	set_cursor(cursor_start)
	vim.cmd("normal! v")
	set_cursor(cursor_stop)
end

return {
	keymaps = {
		{
			{ "o", "x" },
			"ia",
			function()
				argument(true)
			end,
			{ desc = "Inside argument" },
		},
		{
			{ "o", "x" },
			"aa",
			function()
				argument(false)
			end,
			{ desc = "Around argument" },
		},
	},
}
