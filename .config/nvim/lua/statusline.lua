local mode_names = {
	n = "N",
	no = "N",
	i = "I",
	ic = "I",
	v = "V",
	V = "V",
	["\22"] = "V",
	s = "S",
	S = "S",
	["\19"] = "S",
	R = "R",
	Rv = "R",
	c = "C",
	t = "T",
}

local function git_branch()
	if vim.bo.buftype ~= "" then
		return ""
	end
	local branch =
		vim.fn.system("git -C " .. vim.fn.expand("%:p:h") .. " branch --show-current 2>/dev/null"):gsub("\n", "")
	if branch == "" or branch:match("^fatal") then
		return ""
	end
	if #branch > 15 then
		branch = branch:sub(1, 15) .. "..."
	end
	return " " .. branch .. " |"
end

local function diagnostics()
	local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local parts = {}
	if e > 0 then
		table.insert(parts, "%#DiagnosticError#E:" .. e)
	end
	if w > 0 then
		table.insert(parts, "%#DiagnosticWarn#W:" .. w)
	end
	if #parts == 0 then
		return ""
	end
	return " " .. table.concat(parts, " ") .. "%* |"
end

local function lsp_status()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end
	local names = {}
	for _, c in ipairs(clients) do
		table.insert(names, c.name)
	end
	return " " .. table.concat(names, ",") .. " |"
end

_G.statusline = function()
	local mode = mode_names[vim.fn.mode()] or vim.fn.mode()
	return " "
		.. mode
		.. " |"
		.. git_branch()
		.. " %t"
		.. diagnostics()
		.. " %= %S %= %Y"
		.. lsp_status()
		.. " %02l/%02L "
end

return {
	options = {
		statusline = "%!v:lua.statusline()",
		statuscolumn = "%s%l%#NonText# ",
	},
}
