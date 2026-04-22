vim.lsp.config("gopls", {
	cmd = { "gopls" },
	root_markers = { "go.mod", ".git" },
	filetypes = { "go", "gomod" },
})

vim.lsp.config("vtsls", {
	cmd = { "vtsls", "--stdio" },
	root_markers = { "tsconfig.json", "package.json", ".git" },
	filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
	settings = {
		typescript = {
			preferences = {
				importModuleSpecifier = "relative",
			},
		},
		javascript = {
			preferences = {
				importModuleSpecifier = "relative",
			},
		},
	},
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
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
		"--function-arg-placeholders",
		"--offset-encoding=utf-16",
	},
	root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
	filetypes = { "c", "cpp", "objc", "objcpp" },
})

vim.lsp.config("harper_ls", {
	cmd = { "harper-ls", "--stdio" },
	filetypes = { "markdown", "text", "gitcommit" },
})

vim.lsp.config("clojure_lsp", {
	cmd = { "clojure-lsp" },
	root_markers = { "project.clj", "deps.edn", "build.boot", "shadow-cljs.edn", "bb.edn", ".git" },
	filetypes = { "clojure", "clojurescript", "edn" },
})

vim.lsp.enable({ "gopls", "vtsls", "rust_analyzer", "lua_ls", "clangd", "harper_ls", "clojure_lsp" })

vim.diagnostic.config({
	virtual_text = true,
})

local active = {}
local clear_timer = nil ---@type uv.uv_timer_t?
local show_timer = nil ---@type uv.uv_timer_t?
local visible = false

local function format_item(item)
	local text = "[" .. item.client .. "]"
	if item.title and item.title ~= "" then
		text = text .. " " .. item.title
	end
	if item.message and item.message ~= "" then
		text = text .. ": " .. item.message
	end
	if item.percentage then
		text = text .. string.format(" %d%%", item.percentage)
	end
	return text
end

local function render()
	local parts = {}
	for _, item in pairs(active) do
		parts[#parts + 1] = format_item(item)
	end
	visible = true
	vim.api.nvim_echo({ { table.concat(parts, " | "), "Comment" } }, false, {})
end

local function clear_progress()
	if clear_timer then
		clear_timer:stop()
		clear_timer = nil
	end
	if show_timer then
		show_timer:stop()
		show_timer = nil
	end
	if visible then
		vim.api.nvim_echo({ { "" } }, false, {})
		visible = false
	end
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

				if client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
				end

				-- Manual <C-n> trigger for LSP completion (replaced by autocomplete option in init.lua)
				-- To revert: update `vim.opt.autocomplete = false` from init.lua and uncomment this block
				-- vim.keymap.set("i", "<C-n>", function()
				-- 	if vim.fn.pumvisible() == 1 then
				-- 		local key = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
				-- 		vim.api.nvim_feedkeys(key, "n", false)
				-- 	else
				-- 		vim.lsp.completion.get()
				-- 	end
				-- end, { buffer = ev.buf, desc = "LSP completion" })
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
				vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Find references" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover documentation" })
				vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })

				if client.name == "clangd" then
					vim.keymap.set("n", "<leader>h", function()
						local params = vim.lsp.util.make_text_document_params(ev.buf)
						client:request("textDocument/switchSourceHeader", params, function(err, result)
							if err or not result then
								vim.notify("No matching source/header", vim.log.levels.WARN)
								return
							end
							vim.cmd.edit(vim.uri_to_fname(result))
						end, ev.buf)
					end, { buffer = ev.buf, desc = "Switch C/C++ header/source" })
				end

			end,
		},
		{
			"LspProgress",
			function(ev)
				local value = ev.data.params.value
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local client_name = client and client.name or "lsp"
				local key = ev.data.client_id .. ":" .. tostring(ev.data.params.token)

				if clear_timer then
					clear_timer:stop()
					clear_timer = nil
				end

				if value.kind == "begin" then
					active[key] = {
						client = client_name,
						title = value.title,
						message = value.message,
						percentage = value.percentage,
					}
					if visible then
						render()
					elseif not show_timer then
						show_timer = vim.uv.new_timer()
						if show_timer then
							show_timer:start(
								500,
								0,
								vim.schedule_wrap(function()
									show_timer = nil
									if next(active) then
										render()
									end
								end)
							)
						end
					end
				elseif value.kind == "report" then
					local item = active[key]
					if item then
						item.message = value.message or item.message
						item.percentage = value.percentage or item.percentage
						if visible then
							render()
						end
					end
				elseif value.kind == "end" then
					active[key] = nil
					if next(active) == nil then
						if visible then
							clear_timer = vim.uv.new_timer()
							if clear_timer then
								clear_timer:start(500, 0, vim.schedule_wrap(clear_progress))
							end
						elseif show_timer then
							show_timer:stop()
							show_timer = nil
						end
					elseif visible then
						render()
					end
				end
			end,
		},
	},
}
