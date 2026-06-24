-- Third-party plugin installation (vim.pack.add) + per-plugin setup().
-- Contributes: nothing through the module contract — everything runs as
-- side effects at require-time. This file owns: jump, nvim-dap, snacks.nvim,
-- nvim-autopairs, conform.nvim, nvim-lint, and `present.nvim` (self-authored).
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

-- nvim-dap (used by tools/dap.lua for lldb-based C/C++/ObjC debugging)
vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })

-- nvim-lspconfig: ships per-server configs as lsp/<server>.lua files that the
-- 0.11+ native LSP picks up via vim.lsp.config / vim.lsp.enable. Servers are
-- enabled in lua/tools/lsp.lua.
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- ziglang/zig.vim: Zig syntax highlighting, filetype detection, and integrations.
vim.g.zig_fmt_autosave = 0 -- disable format-on-save from zig.vim, conform handles it
vim.pack.add({ "https://codeberg.org/ziglang/zig.vim" })

-- nvim-treesitter: parser installer only (highlighting handled by treesitter.lua)
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- fzf-lua: file picker, live grep, and api discovery
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
	explorer = { enabled = true, replace_netrw = false },
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
						require("fzf-lua").files()
					end,
				},
				{
					icon = " ",
					key = "g",
					desc = "Live grep",
					action = function()
						require("fzf-lua").live_grep()
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

-- nvim-autopairs: insert/skip pairs, <BS> deletes both halves, <CR> expands
-- {|} into a multi-line block. Treesitter-aware (no autopair inside strings/
-- comments where it would be wrong, e.g. apostrophe in "don't").
vim.pack.add({ "https://github.com/windwp/nvim-autopairs" })
require("nvim-autopairs").setup({
	check_ts = true,
	fast_wrap = {},
})

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
		require("lint").try_lint(nil, {
			filter = function(linter)
				local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
				return vim.fn.executable(cmd) == 1
			end,
		})
	end,
})

-- Omarchy theme plugins. Installed so that theme switching via the
-- ~/.config/omarchy/hooks/theme-set hook works with this config.
-- Omarchy is Linux-only, so skip on macOS.
if vim.uv.os_uname().sysname == "Linux" then
	vim.pack.add({ "https://github.com/catppuccin/nvim" }) -- catppuccin, catppuccin-latte
	vim.pack.add({ "https://github.com/bjarneo/ethereal.nvim" }) -- ethereal
	vim.pack.add({ "https://github.com/neanias/everforest-nvim" }) -- everforest
	vim.pack.add({ "https://github.com/kepano/flexoki-neovim" }) -- flexoki-light
	vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" }) -- gruvbox
	vim.pack.add({ "https://github.com/bjarneo/aether.nvim" }) -- hackerman dependency
	vim.pack.add({ "https://github.com/bjarneo/hackerman.nvim" }) -- hackerman
	vim.pack.add({ "https://github.com/rebelot/kanagawa.nvim" }) -- kanagawa
	vim.pack.add({ "https://github.com/omacom-io/lumon.nvim" }) -- lumon
	vim.pack.add({ "https://github.com/tahayvr/matteblack.nvim" }) -- matte-black
	vim.pack.add({ "https://github.com/OldJobobo/miasma.nvim" }) -- miasma
	vim.pack.add({ "https://github.com/EdenEast/nightfox.nvim" }) -- nord (nordfox colorscheme)
	vim.pack.add({ "https://github.com/ribru17/bamboo.nvim" }) -- osaka-jade (bamboo colorscheme)
	vim.pack.add({ "https://github.com/OldJobobo/retro-82.nvim" }) -- retro-82
	vim.pack.add({ "https://github.com/gthelding/monokai-pro.nvim" }) -- ristretto (monokai-pro)
	vim.pack.add({ "https://github.com/rose-pine/neovim" }) -- rose-pine (rose-pine-dawn colorscheme)
	vim.pack.add({ "https://github.com/folke/tokyonight.nvim" }) -- tokyo-night (tokyonight-night colorscheme)
	vim.pack.add({ "https://github.com/bjarneo/vantablack.nvim" }) -- vantablack
	vim.pack.add({ "https://github.com/bjarneo/white.nvim" }) -- white
end
