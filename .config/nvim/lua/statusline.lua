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

local cached_branch = ""

local function update_branch()
	if vim.bo.buftype ~= "" then
		cached_branch = ""
		return
	end
	local dir = vim.fn.expand("%:p:h")
	if dir == "" then
		cached_branch = ""
		return
	end
	vim.system({ "git", "-C", dir, "branch", "--show-current" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 or result.stdout == "" then
				cached_branch = ""
			else
				local branch = result.stdout:gsub("\n", "")
				if #branch > 15 then
					branch = branch:sub(1, 15) .. "..."
				end
				cached_branch = " " .. branch .. " |"
			end
			vim.cmd.redrawstatus()
		end)
	end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
	callback = update_branch,
})

local function git_branch()
	return cached_branch
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
