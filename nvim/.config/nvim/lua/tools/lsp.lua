-- Native Neovim LSP via nvim-lspconfig (vim.lsp.config / vim.lsp.enable).
-- Contributes: autocmds (LspAttach buffer-local maps). Servers are picked up
-- from lspconfig's lsp/<name>.lua files. Disable by commenting out
-- "tools/lsp" in init.lua's module list.

local servers = {
	"lua_ls",
	"gopls",
	"ts_ls",
	"clangd",
	"pyright",
	"rust_analyzer",
	"clojure_lsp",
	"zls",
}

-- Teach lua_ls about Neovim's runtime when there's no project-local .luarc.json.
-- Recommended snippet from lua-language-server's docs.
vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME, "${3rd}/luv/library" },
			},
		})
	end,
	settings = { Lua = {} },
})

-- clangd: enable clang-tidy diagnostics in-process (replaces nvim-lint's clangtidy).
vim.lsp.config("clangd", {
	cmd = { "clangd", "--clang-tidy" },
})

-- rust-analyzer: run clippy on save instead of `cargo check` (replaces nvim-lint's clippy).
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
		},
	},
})

vim.lsp.enable(servers)

vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { prefix = "●" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
	underline = true,
	update_in_insert = false,
	float = { border = "rounded" },
})

return {
	autocmds = {
		{
			"LspAttach",
			function(args)
				local bufnr = args.buf
				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
				end
				-- These override the global tags/grep/substitute maps for buffers
				-- with an LSP attached; non-LSP buffers keep the global behavior.
				map("gd", vim.lsp.buf.definition, "LSP: go to definition")
				map("gD", vim.lsp.buf.declaration, "LSP: go to declaration")
				map("gr", vim.lsp.buf.references, "LSP: references")
				map("gi", vim.lsp.buf.implementation, "LSP: implementation")
				map("gy", vim.lsp.buf.type_definition, "LSP: type definition")
				map("K", vim.lsp.buf.hover, "LSP: hover")
				map("<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
				map("<leader>rn", vim.lsp.buf.rename, "LSP: rename symbol")
				map("[d", function()
					vim.diagnostic.jump({ count = -1 })
				end, "Prev diagnostic")
				map("]d", function()
					vim.diagnostic.jump({ count = 1 })
				end, "Next diagnostic")
			end,
		},
	},
}
