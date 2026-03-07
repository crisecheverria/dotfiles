vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/mcauley-penney/techbase.nvim" },
	{ src = "https://github.com/folke/tokyonight.nvim.git" },
	{ src = "https://github.com/tahayvr/matteblack.nvim" },
	{ src = "https://github.com/ellisonleao/gruvbox.nvim" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
	{ src = "https://github.com/craftzdog/solarized-osaka.nvim" },
	{ src = "https://github.com/aymenhafeez/doric-themes.nvim" },
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/rodolfo-arg/gentleman-kanagawa-blur" },
	{ src = "https://github.com/Alan-TheGentleman/oldworld.nvim" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
}, { load = true })

-- Catppuccin (mocha, transparent)
require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	term_colors = true,
})

-- Kanagawa (wave, transparent)
require("kanagawa").setup({
	compile = false,
	undercurl = true,
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = {},
	typeStyle = {},
	transparent = true,
	dimInactive = false,
	terminalColors = true,
	colors = {
		palette = {},
		theme = {
			wave = {},
			lotus = {},
			dragon = {},
			all = {
				ui = {
					bg_gutter = "none",
					bg_sidebar = "none",
					bg_float = "none",
				},
			},
		},
	},
	overrides = function(colors)
		return {
			LineNr = { bg = "none" },
			NormalFloat = { bg = "none" },
			FloatBorder = { bg = "none" },
			FloatTitle = { bg = "none" },
			TelescopeNormal = { bg = "none" },
			TelescopeBorder = { bg = "none" },
			LspInfoBorder = { bg = "none" },
		}
	end,
	theme = "wave",
	background = {
		dark = "wave",
		light = "lotus",
	},
})

-- Kanso (zen, transparent)
require("kanso").setup({
	transparent = true,
	theme = "zen",
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		operators = {},
		types = {},
	},
})

-- All available colorschemes
local colorschemes = {
	"catppuccin",
	"doric-beach",
	"doric-cherry",
	"doric-copper",
	"doric-dark",
	"doric-earth",
	"doric-fire",
	"doric-jade",
	"doric-light",
	"doric-marble",
	"doric-mermaid",
	"doric-oak",
	"doric-obsidian",
	"doric-pine",
	"doric-plum",
	"doric-siren",
	"doric-valley",
	"doric-water",
	"doric-wind",
	"gentleman-kanagawa-blur",
	"gruvbox",
	"gruvbox-material",
	"kanagawa",
	"kanso",
	"matteblack",
	"oldworld",
	"solarized-osaka",
	"techbase",
	"tokyonight",
	"vague",
}

local function apply_post_colorscheme()
	vim.cmd(":hi statusline guibg=NONE")
end

local function persist_colorscheme(name)
	local config_path = vim.fn.stdpath("config") .. "/lua/plugins/colorscheme.lua"
	local file = io.open(config_path, "r")
	if not file then
		return
	end
	local lines = {}
	for line in file:lines() do
		if line:match('^vim%.cmd%("colorscheme ') then
			table.insert(lines, 'vim.cmd("colorscheme ' .. name .. '")')
		else
			table.insert(lines, line)
		end
	end
	file:close()
	file = io.open(config_path, "w")
	if file then
		file:write(table.concat(lines, "\n") .. "\n")
		file:close()
	end
end

local function pick_colorscheme()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, colorschemes)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local original = vim.g.colors_name or "default"

	local width = 30
	local height = math.min(#colorschemes, 30)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Colorschemes ",
		title_pos = "center",
	})

	-- Live preview on cursor move
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buf,
		callback = function()
			local idx = vim.api.nvim_win_get_cursor(win)[1]
			pcall(vim.cmd, "colorscheme " .. colorschemes[idx])
			apply_post_colorscheme()
		end,
	})

	-- Cancel: revert to original
	local function cancel()
		vim.api.nvim_win_close(win, true)
		pcall(vim.cmd, "colorscheme " .. original)
		apply_post_colorscheme()
	end

	vim.keymap.set("n", "q", cancel, { buffer = buf })
	vim.keymap.set("n", "<Esc>", cancel, { buffer = buf })

	-- Confirm selection
	vim.keymap.set("n", "<CR>", function()
		local idx = vim.api.nvim_win_get_cursor(win)[1]
		local name = colorschemes[idx]
		vim.api.nvim_win_close(win, true)
		vim.cmd("colorscheme " .. name)
		apply_post_colorscheme()
		persist_colorscheme(name)
		vim.notify("Colorscheme: " .. name, vim.log.levels.INFO)
	end, { buffer = buf })
end

vim.keymap.set("n", "<leader>cs", pick_colorscheme, { desc = "Pick Colorscheme" })

-- Active colorscheme
vim.cmd("colorscheme oldworld")
apply_post_colorscheme()
