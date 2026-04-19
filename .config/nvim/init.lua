-- Neovim 0.12 experimental UI2: redesigned messages and command-line
require("vim._core.ui2").enable({})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.mouse = ""
vim.opt.complete = ".,w,b,u,o"
vim.opt.completeopt = "fuzzy,noselect,menuone,popup,nearest"
-- Nvim 0.12: auto-trigger completion as you type (set to false to go back to manual <C-n>)
vim.opt.autocomplete = true
vim.opt.wildmode = "noselect:longest"
vim.opt.wildoptions = "fuzzy,pum"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.cmdheight = 0
vim.opt.scrolloff = 5
vim.opt.showcmd = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.virtualedit = "block"
vim.opt.clipboard = "unnamedplus"
vim.opt.textwidth = 80
vim.opt.formatoptions = "crl1"
vim.opt.pumheight = 20
vim.opt.pumborder = "rounded"
vim.opt.compatible = false
vim.opt.path = "**"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.g.mapleader = ";"

vim.g.loaded_matchit = 1
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.g.loaded_remote_plugins = 1
vim.g.loaded_shada_plugin = 1
vim.g.loaded_python3_provider = 0
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Auto-reload buffers when the underlying file is changed externally.
-- `autoread` alone is not enough: Neovim only checks the file's mtime on
-- specific events. Without this autocmd, edits made by external tools
-- (Claude Code, formatters, `git pull`, etc.) are not reflected in open
-- buffers until you manually run `:e`. CursorHold fires after `updatetime`
-- ms of inactivity, which catches the common case of staring at a buffer
-- right after an external write. The `mode() ~= "c"` guard avoids
-- triggering `:checktime` while the cmdline is open.
--
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- Surface silent reloads so it's obvious a buffer was refreshed from disk.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	pattern = "*",
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
	end,
})

-- Load Cfilter optional package
vim.cmd.packadd("cfilter")

-- Load persisted colorscheme or fall back to darkblue
local colorscheme_file = vim.fn.stdpath("data") .. "/colorscheme"
local f = io.open(colorscheme_file, "r")
local saved = f and f:read("*l")
if f then
	f:close()
end
vim.cmd.colorscheme(saved ~= "" and saved or "darkblue")

local utils = require("utils")
-- Load configuration fragments
local configurations = {}
for _, config in pairs({
	"plugins",
	"statusline",
	"keymaps",
	"commands",
	"treesitter",
	"tools/find",
	"tools/textobjects",
	"tools/qf",
	"tools/languages",
	"tools/git",
	"tools/lsp",
	"tools/dap",
	"tools/ai",
}) do
	package.loaded[config] = false
	local config_setup = require(config)
	if type(config_setup) == "table" then
		for key, value in pairs(config_setup) do
			configurations[key] = utils.merge_table(configurations[key], value)
		end
	end
end

function check_keymap(modes, lhs, rhs)
	assert(type(modes) == "table", "invalid 'modes' type")
	for _, mode in pairs(modes) do
		local previous = vim.fn.maparg(lhs, mode)
		assert(
			string.len(previous) == 0,
			string.format("multiple declaration of keymap '%s' in mode %s: '%s' & '%s'", lhs, mode, rhs, previous)
		)
	end
end

-- Clear all mappings that would have been created by plugins and set our owns
vim.cmd.mapclear()
-- Restore built-in comment mappings (gc/gcc) cleared by mapclear
vim.keymap.set({ "n", "x" }, "gc", function()
	return require("vim._comment").operator()
end, { expr = true, desc = "Toggle comment" })
vim.keymap.set("n", "gcc", function()
	return require("vim._comment").operator() .. "_"
end, { expr = true, desc = "Toggle comment line" })
vim.keymap.set("o", "gc", function()
	require("vim._comment").textobject()
end, { desc = "Comment textobject" })
-- Restore built-in incremental treesitter selection cleared by mapclear
vim.keymap.set({ "x" }, "[n", function()
	require("vim.treesitter._select").select_prev(vim.v.count1)
end, { desc = "Select previous node" })
vim.keymap.set({ "x" }, "]n", function()
	require("vim.treesitter._select").select_next(vim.v.count1)
end, { desc = "Select next node" })
vim.keymap.set({ "x", "o" }, "an", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_parent(vim.v.count1)
	else
		vim.lsp.buf.selection_range(vim.v.count1)
	end
end, { desc = "Select parent (outer) node" })
vim.keymap.set({ "x", "o" }, "in", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_child(vim.v.count1)
	else
		vim.lsp.buf.selection_range(-vim.v.count1)
	end
end, { desc = "Select child (inner) node" })
local explicit_lhs = {}
for _, keymap in pairs(configurations.keymaps or {}) do
	for _, m in pairs(keymap[1]) do
		explicit_lhs[m .. keymap[2]] = true
	end
end

for _, keymap in pairs(configurations.keymaps or {}) do
	local mode, lhs, rhs, opts = unpack(keymap)

	check_keymap(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, opts)
	if type(rhs) ~= "function" then
		local left, right = string.find(rhs, "<[ACS]%-%a>")
		local len = string.len(rhs)
		if len == 1 or (left == 1 and right == len) then
			local skip = false
			for _, m in pairs(mode) do
				if explicit_lhs[m .. rhs] then
					skip = true
					break
				end
			end
			if not skip then
				vim.keymap.set(mode, rhs, "<Nop>")
			end
		end
	end
end

-- Unset unwanted default bindings
for _, unbind in pairs(configurations.unbinds or {}) do
	local mode, lhs, opts = unpack(unbind)
	vim.keymap.set(mode, lhs, "<Nop>", opts)
end

-- Load autocommands
vim.api.nvim_create_augroup("Config", { clear = true })
for _, au in pairs(configurations.autocmds or {}) do
	local events, fn, opts = unpack(au)
	vim.api.nvim_create_autocmd(
		events,
		vim.tbl_extend("error", {
			group = "Config",
			callback = fn,
		}, opts or {})
	)
end

-- Load custom user commands
for _, user in pairs(configurations.usercmds or {}) do
	local name, callback, opts = unpack(user)
	vim.api.nvim_create_user_command(name, callback, opts or {})
end

-- Load options
for name, value in pairs(configurations.options or {}) do
	vim.opt[name] = value
end
