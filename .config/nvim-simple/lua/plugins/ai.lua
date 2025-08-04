vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' }, -- Required by many plugins (codecompanion)
	{ src = 'https://github.com/olimorris/codecompanion.nvim' },
  { src = "https://github.com/github/copilot.vim" },
})

require "codecompanion".setup()

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
