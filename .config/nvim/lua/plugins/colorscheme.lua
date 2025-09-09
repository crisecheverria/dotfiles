vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/mcauley-penney/techbase.nvim" },
  { src = "https://github.com/folke/tokyonight.nvim.git" }
})

--require('techbase').setup({})
require("tokyonight").setup({ transparent = true, styles = { sidebars = "transparent", floats = "transparent", }, })


-- require "vague".setup({ transparent = true })

--vim.cmd("colorscheme techbase")
-- vim.cmd("colorscheme vague")
vim.cmd [[colorscheme tokyonight]]
-- Remove statusline background color
-- vim.cmd(":hi statusline guibg=NONE")
