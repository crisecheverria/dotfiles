vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"

-- Neovim own plugin manager
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" }, -- Colorscheme
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.cmd("set completeopt+=noselect")

-- Plugins setup
require "mini.pick".setup()
require "oil".setup()
require "vague".setup({ transparent = true })
require "nvim-treesitter.configs".setup({
	ensure_installed = { "go", "python", "typescript", "javascript" },
	highlight = { enable = true }
})

vim.lsp.enable({ "lua_ls", "vtsls", "gopls", "pylsp", "eslint" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format) -- Format buffer
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)     -- Go to definition
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")     -- Mini.pick Find File
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")     -- Documentation
vim.keymap.set('n', '<leader>e', ":Oil<CR>")

vim.cmd("colorscheme vague")
-- Remove statusline background color
vim.cmd(":hi statusline guibg=NONE")
