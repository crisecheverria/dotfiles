local module = {}
local fzf = require("fzf-lua")

local rules = {
	Golang = {
		Function = [[^func +(?:\([a-zA-Z0-9_]+ +\*?[a-zA-Z0-9_]+(?:\[.+\])?\))? *[A-Z][a-zA-Z0-9_]* -- !*test* ]],
		Type = [[^type +[A-Z][a-zA-Z0-9_]+ -- !*test* ]],
	},
	Lua = {
		Function = [[(?:function [a-zA-Z0-9_]+\(|[a-zA-Z0-9_]+ = function\(|= def\()]],
	},
	Rust = {
		-- We don't filter by file extension because Rust API searches often target
		-- individual files, unlike Go, where the package system makes it
		-- more common to search the entire directory.
		Function_and_Macro = [[(^\s*pub (const )?(unsafe )?fn +[a-zA-Z0-9_#]+|^\s*macro_rules! [a-zA-Z0-9_#]+|^impl )]],
		Type = [[^\s*pub (?:struct|union|enum|trait|type) [a-zA-Z0-9_#]+]],
	},
}

local parse_programming_language = function(path)
	if path:match("%.go$") or path == "go.mod" then
		return "Golang"
	elseif path:match("%.lua$") then
		return "Lua"
	elseif path:match("%.rs$") or path:lower() == "cargo.toml" then
		return "Rust"
	end
	return nil
end

module.module_api_search = function()
	local path = vim.api.nvim_buf_get_name(0)
	local operation = fzf.grep

	local programming_language = nil
	if not path:match("^oil://.*") then
		programming_language = parse_programming_language(path)
	else
		local handle = vim.uv.fs_scandir(vim.uv.cwd())
		if handle then
			while true do
				local name, t = vim.uv.fs_scandir_next(handle)
				if not name then
					break
				end
				if t == "file" then
					programming_language = parse_programming_language(name)
					if programming_language then
						break
					end
				end
			end
		end
	end
	if programming_language == nil then
		fzf.live_grep()
		return
	else
		if not path:match("^oil://.*") and (programming_language == "Rust" or programming_language == "Lua") then
			operation = fzf.grep_curbuf
		end
		local items = {}
		for item in pairs(rules[programming_language]) do
			table.insert(items, item)
		end
		table.sort(items)
		table.insert(items, "Any")
		fzf.fzf_exec(items, {
			prompt = string.format("Search Package (%s) > ", programming_language),
			actions = {
				["default"] = function(selected, opts)
					if selected == nil then
						return
					end
					selected = selected[1]
					if selected == "Any" then
						fzf.live_grep()
					else
						operation({
							search = rules[programming_language][selected],
							no_esc = true,
							-- Error: unable to init vim.regex
							-- https://github.com/ibhagwan/fzf-lua/issues/1858#issuecomment-2689899556
							-- The message is mostly informational, this happens due to the
							-- previewer trying to convert the regex to vim magic pattern (in
							-- order to highlight it), but not all cases can be covered so the
							-- previewer will highlight the cursor column only (instead of the
							-- entire pattern).
							silent = true,
						})
					end
				end,
			},
		})
	end
end

return module
