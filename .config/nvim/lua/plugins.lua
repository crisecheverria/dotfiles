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

-- snacks.nvim (used by claudecode.nvim for floating terminal, and as a
-- global picker). Dashboard is NOT used — snacks' header extmarks fight
-- with milli's coloring and suppress the animation; we roll our own below.
vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
	picker = { enabled = true },
})

-- milli.nvim: animated ASCII splash + custom keys menu on startup. Avoids
-- snacks dashboard because that applies a single `Title` highlight across
-- the whole header extmark, which flattens milli's colors and makes the
-- animation imperceptible. `:MilliPreview <name>` to try other splashes.
vim.pack.add({ "https://github.com/amansingh-afk/milli.nvim" })
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() > 0 then
			return
		end
		local milli = require("milli")
		local opts = { splash = "aiface", loop = true }
		local ok, data = pcall(milli.load, opts)
		if not ok or not data or not data.frames or not data.frames[1] then
			return
		end

		local frame = data.frames[1]
		local frame_w = 0
		for _, line in ipairs(frame) do
			local w = vim.fn.strdisplaywidth(line)
			if w > frame_w then
				frame_w = w
			end
		end

		local keys = {
			{ "f", "Find file", function() require("fff").find_files() end },
			{ "g", "Live grep", function() require("fff").live_grep() end },
			{ "r", "Recent files", function() Snacks.picker.recent() end },
			{ "c", "Config", function() vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua") end },
			{ "l", "Lazygit", function() vim.cmd("Lazygit") end },
			{ "q", "Quit", function() vim.cmd("qa") end },
		}

		local keys_w = 32
		local key_lines = {}
		for _, k in ipairs(keys) do
			local gap = keys_w - #k[2] - #k[1]
			key_lines[#key_lines + 1] = k[2] .. string.rep(" ", gap) .. k[1]
		end

		local gap_rows = 2
		local total_h = #frame + gap_rows + #key_lines
		local vpad = math.max(0, math.floor((vim.o.lines - total_h) / 2))
		local hpad_frame = string.rep(" ", math.max(0, math.floor((vim.o.columns - frame_w) / 2)))
		local hpad_keys = string.rep(" ", math.max(0, math.floor((vim.o.columns - keys_w) / 2)))

		local lines = {}
		for _ = 1, vpad do
			lines[#lines + 1] = ""
		end
		for _, line in ipairs(frame) do
			lines[#lines + 1] = hpad_frame .. line
		end
		for _ = 1, gap_rows do
			lines[#lines + 1] = ""
		end
		for _, line in ipairs(key_lines) do
			lines[#lines + 1] = hpad_keys .. line
		end

		local buf = vim.api.nvim_get_current_buf()
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].buflisted = false
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.cursorline = false
		vim.wo.statuscolumn = ""
		vim.wo.signcolumn = "no"

		for _, k in ipairs(keys) do
			vim.keymap.set("n", k[1], k[3], { buffer = buf, nowait = true, silent = true, desc = k[2] })
		end

		milli.play(buf, opts)
	end,
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
