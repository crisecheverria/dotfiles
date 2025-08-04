-- Got it from https://erock-git-dotfiles.pgs.sh/tree/main/item/dot_config/nvim/init.lua.html
local function setup_lsp()
	local augroup = vim.api.nvim_create_augroup("erock.cfg", { clear = true })
	local map = vim.keymap.set
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

	vim.api.nvim_create_autocmd("LspAttach", {
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
				vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
				client.server_capabilities.completionProvider.triggerCharacters = chars
				-- Enable completion resolve for auto-imports
				client.server_capabilities.completionProvider.resolveProvider = true
				vim.lsp.completion.enable(true, client.id, args.buf,
					{ autotrigger = true })

				-- Handle completion resolve for auto-imports on selection
				vim.api.nvim_create_autocmd("CompleteDone", {
					group = augroup,
					buffer = args.buf,
					callback = function()
						local completed_item = vim.v.completed_item
						if completed_item and completed_item.user_data then
							local completion_item = completed_item.user_data.nvim and
							    completed_item.user_data.nvim.lsp and
							    completed_item.user_data.nvim.lsp.completion_item
							if completion_item then
								-- Only use completion resolve for vtsls, let other LSPs handle autoimports normally
								if client.name == "vtsls" then
									client.request("completionItem/resolve",
										completion_item,
										function(err, resolved_item)
											if not err and resolved_item and resolved_item.additionalTextEdits then
												vim.lsp.util
												    .apply_text_edits(
													    resolved_item.additionalTextEdits,
													    args.buf,
													    client.offset_encoding or
													    "utf-16")
											end
										end, args.buf)
								elseif completion_item.additionalTextEdits then
									-- For other LSPs, apply additionalTextEdits directly if they exist
									vim.lsp.util.apply_text_edits(
										completion_item.additionalTextEdits,
										args.buf,
										client.offset_encoding or "utf-16")
								end
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

-- Diagnostics configuration
vim.diagnostic.config({
	virtual_lines = {
		current_line = true
	}
})
