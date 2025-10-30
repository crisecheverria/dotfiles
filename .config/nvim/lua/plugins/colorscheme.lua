vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/mcauley-penney/techbase.nvim" },
	{ src = "https://github.com/folke/tokyonight.nvim.git" },
	{ src = "https://github.com/tahayvr/matteblack.nvim" },
	{ src = "https://github.com/ellisonleao/gruvbox.nvim" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
}, { load = true })

--require('techbase').setup({})
-- require("tokyonight").setup({ transparent = true, styles = { sidebars = "transparent", floats = "transparent" } })
-- require "vague".setup({ transparent = true })
-- require("matteblack").colorscheme()
-- require("gruvbox").setup({ contrast = "hard", transparent_mode = false })
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_transparent_background = 0

--vim.cmd("colorscheme techbase")
-- vim.cmd("colorscheme vague")
-- vim.cmd([[colorscheme tokyonight]])
-- vim.cmd([[colorscheme matteblack]])
-- vim.cmd("colorscheme gruvbox")
vim.cmd("colorscheme gruvbox-material")

-- Remove statusline background color
-- vim.cmd(":hi statusline guibg=NONE")
