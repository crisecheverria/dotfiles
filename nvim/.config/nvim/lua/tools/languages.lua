-- Per-filetype configuration (indent, build commands).
-- Contributes: autocmds (FileType handlers).
-- Per-filetype: lua/go indent (3/4), js/ts indent=2, c/cpp cmake build
-- + <leader>m / <leader>R, ghostty commentstring. Linting lives in
-- nvim-lint (see plugins.lua). Disabling drops these niceties;
-- treesitter still works.

local function lua_config()
	vim.bo.tabstop = 3
	vim.bo.shiftwidth = 3
end

local function go_config()
	vim.bo.tabstop = 4
	vim.bo.shiftwidth = 4
end

local function js_ts_config()
	vim.bo.tabstop = 2
	vim.bo.shiftwidth = 2
end

local function cpp_config()
	-- Treat `::` as part of a keyword so K on `std::vector` grabs the full token.
	vim.opt_local.iskeyword:append(":")

	-- Bypass :Man for K — Neovim nightly's :tag chokes on `std::vector(3)`
	-- with E1576 ("URL-shaped" tag entry). Run man in a terminal split instead.
	vim.keymap.set("n", "K", function()
		local word = vim.fn.expand("<cword>")
		if word == "" then
			return
		end
		vim.cmd("botright 20split")
		vim.cmd("terminal man " .. vim.fn.shellescape(word))
		vim.bo.buflisted = false
		vim.keymap.set("n", "q", "<cmd>bdelete!<cr>", { buffer = 0, silent = true })
	end, { buffer = 0, desc = "man <cword>" })

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
