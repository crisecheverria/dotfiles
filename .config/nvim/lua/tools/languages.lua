-- Per-filetype configuration (indent, linters, build commands).
-- Contributes: autocmds (FileType handlers).
-- Per-filetype: lua/go indent (3/4), js/ts eslint + indent=2, c/cpp cmake
-- build + <leader>m / <leader>R, ghostty commentstring. Disabling drops
-- these niceties; LSP and treesitter still work.

local function lua_config()
	vim.bo.tabstop = 3
	vim.bo.shiftwidth = 3
end

local function go_config()
	vim.bo.tabstop = 4
	vim.bo.shiftwidth = 4
end

local eslint_ns = vim.api.nvim_create_namespace("eslint")

local function eslint_lint(bufnr, eslint_bin)
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		return
	end

	vim.system(
		{ eslint_bin, "--format", "json", file },
		{ text = true },
		vim.schedule_wrap(function(result)
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			vim.diagnostic.reset(eslint_ns, bufnr)

			if not result.stdout or result.stdout == "" then
				return
			end

			local ok, parsed = pcall(vim.json.decode, result.stdout)
			if not ok or not parsed or not parsed[1] or not parsed[1].messages then
				return
			end

			local diagnostics = {}
			for _, msg in ipairs(parsed[1].messages) do
				table.insert(diagnostics, {
					lnum = (msg.line or 1) - 1,
					col = (msg.column or 1) - 1,
					end_lnum = msg.endLine and (msg.endLine - 1) or nil,
					end_col = msg.endColumn and (msg.endColumn - 1) or nil,
					message = msg.message,
					source = "eslint",
					severity = msg.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
				})
			end

			vim.diagnostic.set(eslint_ns, bufnr, diagnostics)
		end)
	)
end

local function find_local_bin(name)
	local dir = vim.fn.expand("%:p:h")
	local local_bin = vim.fn.findfile("node_modules/.bin/" .. name, dir .. ";")
	if local_bin ~= "" then
		return vim.fn.fnamemodify(local_bin, ":p")
	end
	return vim.fn.executable(name) == 1 and name or nil
end

local function js_ts_config()
	local file = vim.api.nvim_buf_get_name(0)
	if file:match("^diffview://") or file:match("^fugitive://") or not vim.uv.fs_stat(file) then
		return
	end

	vim.bo.tabstop = 2
	vim.bo.shiftwidth = 2

	local bufnr = vim.api.nvim_get_current_buf()
	local eslint_bin = find_local_bin("eslint")
	if not eslint_bin then
		return
	end

	eslint_lint(bufnr, eslint_bin)
	vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
		group = "Config",
		buffer = bufnr,
		callback = function()
			eslint_lint(bufnr, eslint_bin)
		end,
	})
end

local function cpp_config()
	local cpp = require("tools.cpp")
	local root = cpp.find_project_root(0)
	if not root then
		return
	end

	local build_dir = root .. "/build"
	vim.bo.makeprg = "cmake --build " .. vim.fn.fnameescape(build_dir) .. " -j"

	vim.keymap.set("n", "<leader>m", "<cmd>make<cr>", { buffer = 0, desc = "Build (cmake)" })
	vim.keymap.set("n", "<leader>R", function()
		local execs = cpp.find_executables(build_dir)
		if #execs == 0 then
			vim.notify("No executables in " .. build_dir .. " — build first", vim.log.levels.WARN)
			return
		end
		local run = function(path)
			vim.cmd("!" .. vim.fn.shellescape(path))
		end
		if #execs == 1 then
			run(execs[1])
		else
			vim.ui.select(execs, { prompt = "Run:" }, function(choice)
				if choice then
					run(choice)
				end
			end)
		end
	end, { buffer = 0, desc = "Run built binary" })
end

local function ghostty_config()
	vim.bo.commentstring = "# %s"
end

return {
	autocmds = {
		{ "Filetype", lua_config, { pattern = "lua" } },
		{ "Filetype", go_config, { pattern = "go" } },
		{ "Filetype", js_ts_config, { pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" } } },
		{ "Filetype", cpp_config, { pattern = { "c", "cpp" } } },
		{ "Filetype", ghostty_config, { pattern = "ghostty" } },
	},
}
