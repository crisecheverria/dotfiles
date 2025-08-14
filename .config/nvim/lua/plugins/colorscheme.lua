vim.pack.add({ "https://github.com/vague2k/vague.nvim" })
vim.pack.add({ "https://github.com/folke/tokyonight.nvim.git" })

require "vague".setup({ transparent = true })

-- vim.cmd("colorscheme vague")
vim.cmd [[colorscheme tokyonight]]
-- Remove statusline background color
-- vim.cmd(":hi statusline guibg=NONE")
