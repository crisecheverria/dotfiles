-- Third-party plugin installation (vim.pack.add) + per-plugin setup().
-- Contributes: nothing through the module contract — everything runs as
-- side effects at require-time. This file owns: jump, llama.vim, nvim-dap,
-- fff.nvim, snacks.nvim, claudecode.nvim, conjure + dispatch (clojure),
-- conform.nvim, render-markdown.nvim, and `present.nvim` (self-authored).
-- Disable: comment out individual `vim.pack.add(...)` blocks below.

-- Installing this plugin because I coded myself, so it doenst count as
-- a plugin:
vim.pack.add({ "https://github.com/crisecheverria/present.nvim" })
require("present").setup()

-- A jump plugin
vim.pack.add({ "https://github.com/yorickpeterse/nvim-jump" })
require("jump").setup({
	labels = "abcdef",
})

-- llama.vim (FIM code completion via local llama.cpp server)
vim.g.llama_config = {
	endpoint_fim = "http://127.0.0.1:8012/infill",
	endpoint_inst = "http://127.0.0.1:8012/v1/chat/completions",
	n_prefix = 512,
	n_suffix = 128,
	n_predict = 128,
	auto_fim = false,
	show_info = 2,
	ring_n_chunks = 32,
	ring_chunk_size = 64,
	ring_scope = 1024,
	-- Don't steal <Esc> from the global noh mapping (keymaps.lua).
	keymap_inst_cancel = "",
}
vim.pack.add({ "https://github.com/ggml-org/llama.vim" })

-- nvim-dap (used by tools/dap.lua for lldb-based C/C++/ObjC debugging)
vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })

-- nvim-lspconfig: ships per-server configs as lsp/<server>.lua files that the
-- 0.11+ native LSP picks up via vim.lsp.config / vim.lsp.enable. Servers are
-- enabled in lua/tools/lsp.lua.
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- ziglang/zig.vim: Zig syntax highlighting, filetype detection, and integrations.
vim.g.zig_fmt_autosave = 0 -- disable format-on-save from zig.vim, conform handles it
vim.pack.add({ "https://codeberg.org/ziglang/zig.vim" })

-- fff.nvim for file picker and grep?
vim.pack.add({ "https://github.com/dmtrKovalenko/fff.nvim" })

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "fff.nvim" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("fff.nvim")
			end
			require("fff.download").download_or_build_binary()
		end
	end,
})

-- the plugin will automatically lazy load
vim.g.fff = {
	lazy_sync = true, -- start syncing only when the picker is open
	debug = {
		enabled = true,
		show_scores = true,
	},
}

-- end fff.nvim pluging

-- Add fzf-lua pluging for api discovery
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
require("fzf-lua").setup({
	defaults = {
		header = false,
	},
	winopts = {
		backdrop = 100,
		fullscreen = true,
		preview = { layout = "vertical", vertical = "down:50%" },
	},
	hls = { normal = "NormalFloat", border = "FloatBorder" },
	keymap = {
		builtin = {
			["<S-Up>"] = "",
			["<S-down>"] = "",
		},
		fzf = {
			["ctrl-h"] = "backward-kill-word",
			["shift-down"] = "half-page-down",
			["shift-up"] = "half-page-up",
			["home"] = "first",
			["end"] = "last",
			["ctrl-q"] = "select-all+accept",
		},
	},
	actions = {
		files = {
			true,
			["enter"] = nil,
			["ctrl-s"] = nil,
			["ctrl-v"] = nil,
			["ctrl-t"] = nil,
			["alt-q"] = nil,
			["alt-Q"] = nil,
			["alt-h"] = nil,
			["alt-f"] = nil,
		},
	},
})

-- snacks.nvim: floating terminal (used by claudecode), global picker, and
-- startup dashboard with a small keys menu.
vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
	picker = {
		enabled = true,
		sources = {
			explorer = { hidden = true }, -- show dotfiles in the tree
		},
	},
	explorer = { enabled = true },
	notifier = {
		enabled = true,
		timeout = 4000,
		style = "compact",
		top_down = true,
	},
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{
					icon = " ",
					key = "f",
					desc = "Find file",
					action = function()
						require("fff").find_files()
					end,
				},
				{
					icon = " ",
					key = "g",
					desc = "Live grep",
					action = function()
						require("fff").live_grep()
					end,
				},
				{ icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{
					icon = " ",
					key = "c",
					desc = "Config",
					action = ":edit " .. vim.fn.stdpath("config") .. "/init.lua",
				},
				{ icon = " ", key = "l", desc = "Lazygit", action = ":Lazygit" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
		},
	},
})

-- Another AI plugin tests :D
vim.pack.add({ "https://github.com/cachebag/jumpy.nvim" })
require("jumpy").setup({
	provider = "anthropic", -- or "openai", "openrouter"
})

-- conjure for clojure. Restrict to clojure filetypes so it doesn't attach
-- (and pop its REPL HUD) on JS/TS/Python buffers.
vim.g["conjure#filetypes"] = { "clojure", "clojurescript", "fennel" }
vim.pack.add({ "https://github.com/Olical/conjure" })

-- nvim-autopairs: insert/skip pairs, <BS> deletes both halves, <CR> expands
-- {|} into a multi-line block. Treesitter-aware (no autopair inside strings/
-- comments where it would be wrong, e.g. apostrophe in "don't").
vim.pack.add({ "https://github.com/windwp/nvim-autopairs" })
require("nvim-autopairs").setup({
	check_ts = true,
	fast_wrap = {},
})
-- be able to run :Lein or Clojure CLI commands inside neovim
-- added dependency of dispatch.vim
-- added dependency of vim-dispatch-neovim
vim.pack.add({ "https://github.com/tpope/vim-dispatch" })
vim.pack.add({ "https://github.com/radenling/vim-dispatch-neovim" })
vim.pack.add({ "https://github.com/clojure-vim/vim-jack-in" })

-- conform.nvim: formatters per filetype, format on save. Filetypes without a
-- declared formatter are skipped — no LSP fallback (conform's default is to
-- not call vim.lsp.buf.format() unless told to).
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
require("conform").setup({
	formatters = {
		["clang-format"] = {
			command = vim.fn.executable("/opt/homebrew/opt/llvm/bin/clang-format") == 1
				and "/opt/homebrew/opt/llvm/bin/clang-format"
				or "clang-format",
		},
		-- eslint_d errors out (and crashes JSON parsing) when a project has no
		-- eslint config. Only run it when one is found upward from the file.
		eslint_d = {
			condition = function(_, ctx)
				return vim.fs.find({
					".eslintrc",
					".eslintrc.json",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.yaml",
					".eslintrc.yml",
					"eslint.config.js",
					"eslint.config.mjs",
					"eslint.config.cjs",
					"eslint.config.ts",
				}, { upward = true, path = ctx.dirname })[1] ~= nil
			end,
		},
	},
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		javascript = { "eslint_d", "prettier" },
		typescript = { "eslint_d", "prettier" },
		javascriptreact = { "eslint_d", "prettier" },
		typescriptreact = { "eslint_d", "prettier" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		clojure = { "cljfmt" },
		clojurescript = { "cljfmt" },
		rust = { "rustfmt" },
		toml = { "taplo" },
		zig = { "zigfmt" },
	},
	format_on_save = { timeout_ms = 5000 },
})

-- nvim-lint: async linters per filetype. Selene runs on Lua buffers; the
-- autocmd kicks off `try_lint` after writes/insert-leaves and on buffer load.
vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })
require("lint").linters_by_ft = {
	lua = { "selene" },
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	-- cpp/clojure intentionally absent: clangd's --clang-tidy,
	-- and clojure-lsp's embedded clj-kondo already provide those diagnostics via LSP.
}

-- Prefer the project-local oxlint binary when present, fall back to PATH.
if require("lint").linters.oxlint then
	require("lint").linters.oxlint.cmd = function()
		local local_bin = vim.fs.find("node_modules/.bin/oxlint", {
			upward = true,
			path = vim.fn.expand("%:p:h"),
		})[1]
		return local_bin or "oxlint"
	end
end

-- Selene reads stdin, so it can't infer the file's location and falls back to
-- nvim's cwd when walking up for selene.toml. Anchor it to the buffer's dir
-- so nvim/selene.toml (and its `vim` std) is found regardless of where nvim
-- was launched.
if require("lint").linters.selene then
	require("lint").linters.selene.cwd = function()
		return vim.fn.expand("%:p:h")
	end
end
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- Markdown files viewer
-- render-markdown.nvim: in-buffer markdown rendering (headings, code fences,
-- bold/italic conceal, etc). Used by the AI chat buffer in lua/tools/ai.lua,
-- which sets conceallevel=2 window-locally so the renderer can hide markup.
vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })
require("render-markdown").setup({})

-- canola.nvim: file manager (drop-in oil.nvim fork; module is `oil`)
vim.pack.add({ "https://github.com/barrettruth/canola.nvim" })
require("oil").setup({
	view_options = { show_hidden = true },
})

-- lazydiff.nvim: inline lazygit-style diff overlay against HEAD
vim.pack.add({ "https://github.com/rashedInt32/lazydiff.nvim" })
require("lazydiff").setup()

-- matugen.nvim: Material You colorscheme driven by ~/.config/matugen/colors.json.
-- Regenerate the JSON with `matugen image <wallpaper>` and the plugin auto-reloads
-- (150ms debounce). Falls back to the MD3 baseline if the file is missing.
vim.pack.add({ "https://github.com/daedlock/matugen.nvim" })
require("matugen").setup({
	colors_path = "~/.config/matugen/colors.json",
})
do
	-- init.lua loaded the persisted scheme before this plugin existed. If the
	-- user previously selected matugen (or has no saved scheme yet), apply it now.
	local f = io.open(vim.fn.stdpath("data") .. "/colorscheme", "r")
	local saved = f and f:read("*l")
	if f then
		f:close()
	end
	if not saved or saved == "" or saved == "matugen" then
		vim.cmd.colorscheme("matugen")
	end
end
