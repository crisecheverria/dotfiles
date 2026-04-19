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

-- claudecode.nvim
vim.pack.add({ "https://github.com/coder/claudecode.nvim" })
require("claudecode").setup({})
