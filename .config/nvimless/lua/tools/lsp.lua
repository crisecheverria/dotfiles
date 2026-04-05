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

vim.lsp.config("clangd", {
	cmd = { "clangd" },
	root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
	filetypes = { "c", "cpp", "objc", "objcpp" },
})

vim.lsp.enable({ "gopls", "vtsls", "rust_analyzer", "lua_ls", "clangd" })

vim.diagnostic.config({
	virtual_text = true,
})

local active_count = 0
local clear_timer = nil

local function clear_progress()
	if clear_timer then
		clear_timer:stop()
		clear_timer = nil
	end
	vim.api.nvim_ui_send("\027]9;4;0\027\\")
end

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

				-- Manual <C-n> trigger for LSP completion (replaced by autocomplete option in init.lua)
				-- To revert: update `vim.opt.autocomplete = false` from init.lua and uncomment this block
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
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })

				if client:supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = ev.buf,
						callback = function()
							vim.lsp.buf.format({ bufnr = ev.buf })
						end,
					})
				end
			end,
		},
		{
			"LspProgress",
			function(ev)
				local value = ev.data.params.value

				if clear_timer then
					clear_timer:stop()
					clear_timer = nil
				end

				if value.kind == "begin" then
					active_count = active_count + 1
					if value.percentage then
						vim.api.nvim_ui_send(string.format("\027]9;4;1;%d\027\\", value.percentage))
					else
						vim.api.nvim_ui_send("\027]9;4;3\027\\")
					end
				elseif value.kind == "report" then
					if value.percentage then
						vim.api.nvim_ui_send(string.format("\027]9;4;1;%d\027\\", value.percentage))
					else
						vim.api.nvim_ui_send("\027]9;4;3\027\\")
					end
				elseif value.kind == "end" then
					active_count = math.max(0, active_count - 1)
					if active_count == 0 then
						vim.api.nvim_ui_send("\027]9;4;1;100\027\\")
						clear_timer = vim.uv.new_timer()
						clear_timer:start(1500, 0, vim.schedule_wrap(clear_progress))
					end
				end
			end,
		},
	},
}
