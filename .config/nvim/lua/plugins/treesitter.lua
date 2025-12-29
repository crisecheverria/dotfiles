vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" } }, { load = true })

-- Setup treesitter with proper error handling
local function setup_treesitter()
	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		vim.notify("nvim-treesitter not found: " .. tostring(treesitter), vim.log.levels.ERROR)
		return
	end

	treesitter.setup({
		ensure_installed = {
			"rust",
			"javascript",
			"typescript",
			"python",
			"go",
			"lua",
			"html",
			"css",
			"json",
			"yaml",
			"toml",
			"markdown",
		},
		auto_install = true,
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
	})
end

-- Try to setup immediately, if not available defer to after plugins are loaded
local ok, _ = pcall(setup_treesitter)
if not ok then
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = setup_treesitter,
		once = true,
	})
end