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

-- snacks.nvim (used by claudecode.nvim for floating terminal)
vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
	picker = { enabled = true },
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
