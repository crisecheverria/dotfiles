-- Third-party plugin installation (vim.pack.add) + per-plugin setup().
-- Contributes: nothing through the module contract — everything runs as
-- side effects at require-time. This file owns: jump, llama.vim, nvim-java,
-- fff.nvim, snacks.nvim, claudecode.nvim, conjure + dispatch (clojure),
-- conform.nvim, md-render.nvim, and `present.nvim` (self-authored).
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

-- Java Setup
vim.pack.add({
	{
		src = "https://github.com/JavaHello/spring-boot.nvim",
	},
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/mfussenegger/nvim-dap",

	"https://github.com/nvim-java/nvim-java",
})

require("java").setup()
vim.lsp.enable("jdtls")
-- end Java setup

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fff_input",
	callback = function(args)
		vim.bo[args.buf].autocomplete = false
	end,
})

-- end fff.nvim pluging

-- snacks.nvim: floating terminal (used by claudecode), global picker, and
-- startup dashboard with a small keys menu.
vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
	picker = { enabled = true },
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

-- claudecode.nvim
vim.pack.add({ "https://github.com/coder/claudecode.nvim" })
require("claudecode").setup({
	terminal = {
		provider = "snacks",
		snacks_win_opts = {
			position = "right",
			width = 0.4,
			height = 0.95,
			border = "rounded",
		},
	},
})

-- 99: agentic AI workflow, using claudecode CLI as the provider.
vim.pack.add({ "https://github.com/ThePrimeagen/99" })
local _99 = require("99")
_99.setup({
	provider = _99.Providers.ClaudeCodeProvider,
	tmp_dir = "./tmp",
	logger = {
		level = _99.DEBUG,
		path = "/tmp/" .. vim.fs.basename(vim.uv.cwd()) .. ".99.debug",
		print_on_error = true,
	},
	md_files = { "CLAUDE.md" },
})

-- conjure for clojure
vim.pack.add({ "https://github.com/Olical/conjure" })
-- be able to run :Lein or Clojure CLI commands inside neovim
-- added dependency of dispatch.vim
-- added dependency of vim-dispatch-neovim
vim.pack.add({ "https://github.com/tpope/vim-dispatch" })
vim.pack.add({ "https://github.com/radenling/vim-dispatch-neovim" })
vim.pack.add({ "https://github.com/clojure-vim/vim-jack-in" })

-- conform.nvim: formatters per filetype, format on save. Filetypes without
-- an explicit formatter fall back to the active LSP formatter.
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
require("conform").setup({
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
	},
	default_format_opts = { lsp_format = "fallback" },
	format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
})

-- Markdown files viewer
vim.pack.add({ "https://github.com/delphinus/md-render.nvim" })

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
