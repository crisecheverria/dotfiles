-- Fuzzy `:find` completion backed by `fd` (falls back to `find`).
-- Contributes: options (sets `findfunc`).
-- Uses vim.fn.matchfuzzy for ranking. Disable to get the built-in
-- literal-match `:find` behavior back.

function _G.CustomFind(arg, _)
	-- TODO: replace with better command
	local cmd = "fd --type file"
	if vim.fn.executable("fd") ~= 1 then
		cmd = "find --type f"
	end
	local files = vim.fn.systemlist(cmd)
	if #arg == 0 then
		return files
	end
	return vim.fn.matchfuzzy(files, arg)
end

return {
	options = {
		findfunc = "v:lua.CustomFind",
	},
}
