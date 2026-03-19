local function format(formatcmd)
	if not vim.bo.modified then
		return
	end
	assert(string.len(vim.bo.formatprg) > 0, "Missing format command")

	local maxline = vim.fn.line("$")
	local lines = vim.api.nvim_buf_get_lines(0, 0, maxline, false)
	local result = vim.system(formatcmd, {
		stdin = lines,
		text = true,
	}):wait()

	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return
	end

	local current_position = vim.fn.winsaveview()
	vim.api.nvim_buf_set_lines(0, 0, maxline, false, vim.fn.split(result.stdout, "\n"))
	vim.fn.winrestview(current_position)
end

local function setup_format(formatcmd)
	local formatprg = formatcmd[1]
	if vim.fn.executable(vim.bo.formatprg) ~= 1 or vim.fn.executable(formatprg) ~= 1 then
		return
	end

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = "Config",
		callback = function()
			format(formatcmd)
		end,
	})
end

local function lua_config()
	vim.bo.formatprg = "stylua"
	vim.bo.tabstop = 3
	vim.bo.shiftwidth = 3

	setup_format({ vim.bo.formatprg, "-" })
end

local function go_config()
	vim.bo.tabstop = 4
	vim.bo.shiftwidth = 4

	setup_format({ vim.bo.formatprg })
end

local function js_ts_config()
	vim.bo.formatprg = "prettier"
	vim.bo.tabstop = 2
	vim.bo.shiftwidth = 2

	setup_format({ vim.bo.formatprg, "--stdin-filepath", vim.api.nvim_buf_get_name(0) })
end

return {
	autocmds = {
		{ "Filetype", lua_config, { pattern = "lua" } },
		{ "Filetype", go_config, { pattern = "go" } },
		{ "Filetype", js_ts_config, { pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" } } },
	},
}
