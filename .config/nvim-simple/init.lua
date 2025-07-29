-- Most of it got it from https://github.com/SylvanFranklin/.config/blob/main/nvim/init.lua
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

vim.cmd("set completeopt+=noselect")

-- Plugins setup
require "mini.pick".setup()
require "oil".setup()
require "vague".setup({ transparent = true })
require "nvim-treesitter.configs".setup({
	ensure_installed = { "go", "python", "typescript", "javascript" },
	highlight = { enable = true }
})

vim.cmd("colorscheme vague")
-- Remove statusline background color
vim.cmd(":hi statusline guibg=NONE")

local map = vim.keymap.set
map('n', '<leader>lf', vim.lsp.buf.format) -- Format buffer
map('n', '<leader>f', ":Pick files<CR>")   -- Mini.pick Find File
map('n', '<leader>H', ":Pick help<CR>")    -- Documentation
map('n', '<leader>e', ":Oil<CR>")

-- Got it from https://erock-git-dotfiles.pgs.sh/tree/main/item/dot_config/nvim/init.lua.html
local opts = { silent = true }
local augroup = vim.api.nvim_create_augroup("erock.cfg", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

local function setup_lsp()
	map("n", "<leader>x", vim.diagnostic.open_float, opts)
	map("n", "<leader>q", vim.diagnostic.setloclist, opts)

	local cfg = vim.lsp.enable
	cfg("cssls") -- npm i -g vscode-langservers-extracted
	cfg("gopls")
	cfg("html")
	cfg("jsonls")
	cfg("pylsp")
	cfg("eslint")
	cfg("ts_ls") -- npm i -g typescript typescript-language-server
	cfg("lua_ls") -- os package mgr: lua-language-server

	local chars = {} -- trigger autocompletion on EVERY keypress
	for i = 32, 126 do
		table.insert(chars, string.char(i))
	end

	autocmd("LspAttach", {
		group = augroup,
		callback = function(args)
			local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
			if client:supports_method("textDocument/implementation") then
				local bufopts = { noremap = true, silent = true, buffer = args.buf }
				map("n", "<leader>d", vim.lsp.buf.definition, bufopts)
				map("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
				map("n", "<leader>h", vim.lsp.buf.hover, bufopts)
				map("n", "<leader>r", vim.lsp.buf.references, bufopts)
				map("n", "<leader>i", vim.lsp.buf.implementation, bufopts)
				map("i", "<C-k>", vim.lsp.completion.get, bufopts) -- open completion menu manually
			end

			if client:supports_method("textDocument/completion") then
				client.server_capabilities.completionProvider.triggerCharacters = chars
				vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
			end
		end,
	})
end

setup_lsp()
-- End
