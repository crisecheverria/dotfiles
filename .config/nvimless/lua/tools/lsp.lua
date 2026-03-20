vim.lsp.config("gopls", {
	cmd = { "gopls" },
	root_markers = { "go.mod", ".git" },
	filetypes = { "go", "gomod" },
})

vim.lsp.config("vtsls", {
	cmd = { "vtsls", "--stdio" },
	root_markers = { "tsconfig.json", "package.json", ".git" },
	filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
})

vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	root_markers = { "Cargo.toml", ".git" },
	filetypes = { "rust" },
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	root_markers = { ".luarc.json", ".git" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})

vim.lsp.enable({ "gopls", "vtsls", "rust_analyzer", "lua_ls" })

return {
	autocmds = {
		{
			"LspAttach",
			function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if not client then
					return
				end

				vim.lsp.completion.enable(true, client.id, ev.buf, {
					convert = function(item)
						local source = ""
						if item.labelDetails and item.labelDetails.description then
							source = item.labelDetails.description
						elseif item.detail then
							source = item.detail
						end
						return { menu = source }
					end,
				})

				vim.keymap.set("i", "<C-n>", function()
					if vim.fn.pumvisible() == 1 then
						local key = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
						vim.api.nvim_feedkeys(key, "n", false)
					else
						vim.lsp.completion.get()
					end
				end, { buffer = ev.buf, desc = "LSP completion" })
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
				vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Find references" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover documentation" })
				vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
			end,
		},
	},
}
