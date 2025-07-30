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

-- Ripgrep with quickfix list
vim.api.nvim_create_user_command("Rg", function(opts)
	local query = opts.args
	local escaped_query = vim.fn.shellescape(query)
	local results = vim.fn.systemlist("rg --vimgrep " .. escaped_query)

	local qf_list = {}
	for _, line in ipairs(results) do
		local file, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
		if file then
			table.insert(qf_list, {
				filename = file,
				lnum = tonumber(lnum),
				col = tonumber(col),
				text = text:gsub("^%s+", "")
			})
		end
	end

	vim.fn.setqflist(qf_list, "r")
	vim.cmd("copen")
end, { nargs = 1 })

map('n', '<leader>g', ":Rg ") -- Ripgrep search

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
	cfg("vtsls") -- npm i -g @vtsls/language-server
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
				map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts) -- code actions for imports
				map("i", "<C-k>", vim.lsp.completion.get, bufopts) -- open completion menu manually
			end

			if client:supports_method("textDocument/completion") then
				client.server_capabilities.completionProvider.triggerCharacters = chars
				-- Enable completion resolve for auto-imports
				client.server_capabilities.completionProvider.resolveProvider = true
				vim.lsp.completion.enable(true, client.id, args.buf,
					{ autotrigger = true })

				-- Handle completion resolve for auto-imports on selection
				autocmd("CompleteDone", {
					group = augroup,
					buffer = args.buf,
					callback = function()
						local completed_item = vim.v.completed_item
						if completed_item and completed_item.user_data then
							local completion_item = completed_item.user_data.nvim and
							    completed_item.user_data.nvim.lsp and
							    completed_item.user_data.nvim.lsp.completion_item
							if completion_item and completion_item.additionalTextEdits then
								vim.lsp.util.apply_text_edits(
									completion_item.additionalTextEdits, args.buf,
									client.offset_encoding or "utf-16")
							end
						end
					end,
				})
			end
		end,
	})
end

setup_lsp()
-- End

-- Autoformat on save (:w)
autocmd("BufWritePre", {
	group = augroup,
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
