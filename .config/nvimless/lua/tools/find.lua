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
	keymaps = {
		{ { "n" }, "<leader>f", ":find<space>", { desc = "Find file (fuzzy)" } },
	},
	options = {
		findfunc = "v:lua.CustomFind",
	},
}
