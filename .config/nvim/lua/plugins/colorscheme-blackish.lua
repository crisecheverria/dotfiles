-- Blackish colorscheme collection (from Rudy.Dots)
-- To use: comment out require("plugins.colorscheme") in init.lua
--         and uncomment require("plugins.colorscheme-blackish")
-- Change the vim.cmd at the bottom to switch between themes.

vim.pack.add({
	"https://github.com/catppuccin/nvim",
	"https://github.com/rodolfo-arg/gentleman-kanagawa-blur",
	"https://github.com/Alan-TheGentleman/oldworld.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/webhooked/kanso.nvim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/craftzdog/solarized-osaka.nvim",
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

-- Tokyonight (night, transparent)
require("tokyonight").setup({
	style = "night",
	transparent = true,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = "transparent",
		floats = "transparent",
	},
	on_highlights = function(highlights)
		local function merge(group, values)
			local existing = highlights[group] or {}
			highlights[group] = vim.tbl_extend("force", existing, values)
		end
		merge("Normal", { bg = "none" })
		merge("NormalFloat", { bg = "none" })
		merge("FloatBorder", { bg = "none" })
		merge("FloatTitle", { bg = "none" })
		merge("TelescopeNormal", { bg = "none" })
		merge("TelescopeBorder", { bg = "none" })
		merge("TelescopeTitle", { bg = "none" })
		merge("LspInfoBorder", { bg = "none" })
		merge("Pmenu", { bg = "none" })
		merge("Keyword", { italic = true })
	end,
})

-- Pick your colorscheme (uncomment one):
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme gentleman-kanagawa-blur")
-- vim.cmd("colorscheme oldworld")
-- vim.cmd("colorscheme kanagawa")
vim.cmd("colorscheme kanso")
-- vim.cmd("colorscheme tokyonight")
