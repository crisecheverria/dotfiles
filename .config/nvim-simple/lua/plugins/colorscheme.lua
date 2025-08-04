vim.pack.add({ "https://github.com/vague2k/vague.nvim" })

require "vague".setup({ transparent = true })

vim.cmd("colorscheme vague")
-- Remove statusline background color
vim.cmd(":hi statusline guibg=NONE")
