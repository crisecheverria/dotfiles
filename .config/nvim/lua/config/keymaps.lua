local map = vim.keymap.set
-- clear search highlights with <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Format Buffer", silent = true })
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition", silent = true })
map("n", "<leader>f", ":FzfLua files<CR>", { desc = "Find File", silent = true })
map("n", "<leader>g", ":FzfLua grep<CR>", { desc = "Grep", silent = true })
map("n", "<leader>r", ":Rg ", { desc = "Rip Grep" })
map("n", "<leader>sw", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd("Rg " .. word)
end, { desc = "Rip Grep current word", silent = true })
map("n", "<leader><leader>", ":FzfLua buffers<CR>", { desc = "Buffers", silent = true })
map("n", "<leader>e", ":Ex<CR>", { desc = "File Explorer", silent = true })
map("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical Split", silent = true })
map("n", "<leader>h", ":split<CR>", { desc = "Horizontal Split", silent = true })
map("n", "<leader>w", ":w<CR>", { desc = "Save", silent = true })
map("n", "<leader>q", ":bd<CR>", { desc = "Close Buffer", silent = true })
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Diagnostics", silent = true })
map("n", "<leader>pu", "<cmd>lua vim.pack.update()<CR>", { desc = "Update plugins", silent = true })

-- vim-test keymaps
map("n", "<leader>tn", ":TestNearest<CR>", { desc = "Test Nearest", silent = true })
map("n", "<leader>tf", ":TestFile<CR>", { desc = "Test File", silent = true })
map("n", "<leader>ts", ":TestSuite<CR>", { desc = "Test Suite", silent = true })
map("n", "<leader>tl", ":TestLast<CR>", { desc = "Test Last", silent = true })
map("n", "<leader>tv", ":TestVisit<CR>", { desc = "Test Visit", silent = true })

-- Git keymaps
map("n", "<leader>dn", "]c", { desc = "Next diff", silent = true })
map("n", "<leader>dp", "[c", { desc = "Previous diff", silent = true })

-- Terminal keymaps
map("n", "<leader>t", ":TestFile<CR>", { desc = "Run Test File", silent = true })
map("n", "<leader>to", function()
	vim.cmd("terminal")
	vim.cmd("startinsert")
end, { noremap = true, silent = true, desc = "Open Terminal" })

-- Run npm build with notification on completion
map("n", "<leader>tb", function()
	vim.notify("Starting build...", vim.log.levels.INFO, { title = "npm build" })

	vim.fn.jobstart("npm run build", {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("Build succeeded!", vim.log.levels.INFO, { title = "npm build" })
			else
				vim.notify("Build failed with code " .. exit_code, vim.log.levels.ERROR, { title = "npm build" })
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})
end, { noremap = true, silent = true, desc = "Build with notification" })

-- Copy relative path of open buffer
map("n", "<leader>cp", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
	print("Copied relative path: " .. vim.fn.expand("%"))
end, { desc = "Copy relative file path" })

-- Clipboard keymaps (paste from system clipboard)
map("n", "p", '"+p', { noremap = true, desc = "Paste from system clipboard" })
map("n", "P", '"+P', { noremap = true, desc = "Paste before from system clipboard" })
map("x", "p", '"+p', { noremap = true, desc = "Paste from system clipboard" })

-- Use ESC to exit terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true })

-- Sidekick plugin keymaps (official + custom)

-- Core Navigation
map({ "n", "x", "i", "t" }, "<tab>", function()
	if not require("sidekick").nes_jump_or_apply() then
		return "<Tab>" -- fallback to normal tab
	end
end, { desc = "Goto/Apply Next Edit Suggestion" })

map({ "n", "t", "i", "v" }, "<C-.>", function()
	require("sidekick.cli").toggle({ focus = true })
end, { desc = "Sidekick Toggle CLI" })

-- CLI Tool Controls
map({ "n", "v" }, "<leader>aa", function()
	require("sidekick.cli").toggle({ focus = true })
end, { desc = "Sidekick Open/Toggle CLI" })

map({ "n", "v" }, "<leader>as", function()
	require("sidekick.cli").select()
end, { desc = "Sidekick Select CLI Tool" })

map({ "n", "v" }, "<leader>ad", function()
	require("sidekick.cli").detach()
end, { desc = "Sidekick Detach/Close Session" })

map({ "n", "v" }, "<leader>ap", function()
	require("sidekick.cli").prompt()
end, { desc = "Sidekick Select Prompt/Context" })

-- Context Sending
map({ "n", "v" }, "<leader>at", function()
	require("sidekick.cli").send()
end, { desc = "Sidekick Send Selection/Context" })

map({ "n", "v" }, "<leader>af", function()
	require("sidekick.cli").send_file()
end, { desc = "Sidekick Send File" })

map("v", "<leader>av", function()
	require("sidekick.cli").send_visual()
end, { desc = "Sidekick Send Visual Selection" })

-- Custom: specific CLI toggles
map({ "n", "v" }, "<leader>ac", function()
	require("sidekick.cli").toggle({ name = "claude", focus = true })
end, { desc = "Sidekick Claude Toggle" })

map({ "n", "v" }, "<leader>ag", function()
	require("sidekick.cli").toggle({ name = "grok", focus = true })
end, { desc = "Sidekick Grok Toggle" })
