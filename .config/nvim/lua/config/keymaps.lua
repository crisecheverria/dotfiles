local map = vim.keymap.set

-- Better navigation for wrapped lines
map("n", "j", "gj", { noremap = true, desc = "Move down by visual line" })
map("n", "k", "gk", { noremap = true, desc = "Move up by visual line" })

-- clear search highlights with <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Format Buffer", silent = true })
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition", silent = true })
map("n", "<leader>f", ":FzfLua files<CR>", { desc = "Find File", silent = true })
map("n", "<leader>g", ":FzfLua live_grep<CR>", { desc = "Grep", silent = true })
map("n", "<leader>r", ":Rg ", { desc = "Rip Grep" })
map("n", "<leader>sw", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd("Rg " .. word)
end, { desc = "Rip Grep current word", silent = true })
map("n", "<leader><leader>", ":FzfLua buffers<CR>", { desc = "Buffers", silent = true })
map("n", "<leader>e", ":Ex<CR>", { desc = "File Explorer", silent = true })
map("n", "<leader>vs", ":vsplit<CR>", { desc = "Vertical Split", silent = true })
map("n", "<leader>hs", ":split<CR>", { desc = "Horizontal Split", silent = true })
map("n", "<leader>w", ":w<CR>", { desc = "Save", silent = true })
map("n", "<leader>q", ":bd<CR>", { desc = "Close Buffer", silent = true })
map("n", "<leader>n", ":bnext<CR>", { desc = "Next Buffer", silent = true })
map("n", "<leader>b", ":bprevious<CR>", { desc = "Previous Buffer", silent = true })
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Diagnostics", silent = true })
map("n", "<leader>pu", function()
	vim.cmd("terminal " .. vim.fn.stdpath("config") .. "/update_plugins.sh")
end, { desc = "Update plugins", silent = true })

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

-- Use ESC to exit terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true })

-- Sidekick plugin keymaps (official + custom)

-- Core Navigation
map({ "n", "x", "i" }, "<tab>", function()
	-- if there is a next edit, jump to it, otherwise apply it if any
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

-- Spring Boot / Java specific keymaps (only active for Java files)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		local opts = { buffer = true, silent = true }

		-- Java testing with nvim-java
		map("n", "<leader>jt", function()
			require("java").test.run_current_method()
		end, vim.tbl_extend("force", opts, { desc = "Test Current Method" }))

		map("n", "<leader>jc", function()
			require("java").test.run_current_class()
		end, vim.tbl_extend("force", opts, { desc = "Test Current Class" }))

		map("n", "<leader>js", function()
			require("java").test.run_current_suite()
		end, vim.tbl_extend("force", opts, { desc = "Test Suite" }))

		-- Java refactoring
		map("n", "<leader>rf", function()
			require("java").refactor.extract_method()
		end, vim.tbl_extend("force", opts, { desc = "Extract Method" }))

		map("n", "<leader>rv", function()
			require("java").refactor.extract_variable()
		end, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))

		-- Maven/Gradle commands
		map("n", "<leader>mb", function()
			vim.notify("Starting Maven build...", vim.log.levels.INFO, { title = "Maven" })
			vim.fn.jobstart("./mvnw compile", {
				cwd = vim.fn.getcwd(),
				on_exit = function(_, exit_code)
					if exit_code == 0 then
						vim.notify("Maven build succeeded!", vim.log.levels.INFO, { title = "Maven" })
					else
						vim.notify(
							"Maven build failed with code " .. exit_code,
							vim.log.levels.ERROR,
							{ title = "Maven" }
						)
					end
				end,
			})
		end, vim.tbl_extend("force", opts, { desc = "Maven Build" }))

		map("n", "<leader>mr", function()
			vim.notify("Starting Spring Boot application...", vim.log.levels.INFO, { title = "Spring Boot" })
			vim.fn.jobstart("./mvnw spring-boot:run", {
				cwd = vim.fn.getcwd(),
				on_stdout = function(_, data)
					if data then
						for _, line in ipairs(data) do
							if line:match("Started.*Application") then
								vim.notify(
									"Spring Boot application started!",
									vim.log.levels.INFO,
									{ title = "Spring Boot" }
								)
							end
						end
					end
				end,
			})
		end, vim.tbl_extend("force", opts, { desc = "Maven Spring Boot Run" }))

		map("n", "<leader>mt", function()
			vim.notify("Running Maven tests...", vim.log.levels.INFO, { title = "Maven Test" })
			vim.fn.jobstart("./mvnw test", {
				cwd = vim.fn.getcwd(),
				on_exit = function(_, exit_code)
					if exit_code == 0 then
						vim.notify("All tests passed!", vim.log.levels.INFO, { title = "Maven Test" })
					else
						vim.notify(
							"Tests failed with code " .. exit_code,
							vim.log.levels.ERROR,
							{ title = "Maven Test" }
						)
					end
				end,
			})
		end, vim.tbl_extend("force", opts, { desc = "Maven Test" }))
	end,
})

-- Add a keymap for Zen Mode (zen-mode.nvim)
map("n", "<leader>zm", ":ZenMode<CR>", { desc = "Toggle Zen Mode", silent = true })

-- neogit keymaps
map("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit", silent = true })
map("n", "<leader>gs", ":Neogit<CR>", { desc = "Open Neogit Status", silent = true })
