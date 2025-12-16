-- Format on save using conform.nvim
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Activate nvim-treesitter
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "javascript", "typescrypt", "python", "rust", "lua", "html" },
	callback = function()
		-- syntax highlighting, provided by Neovim
		vim.treesitter.start()
		-- folds, provided by Neovim
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		-- indentation, provided by nvim-treesitter
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- Ripgrep with quickfix list
-- Usage: :Rg <pattern> [path] [flags...]
-- Examples:
--   :Rg searchTerm                          " search in current directory
--   :Rg searchTerm src/                     " search in src/ folder
--   :Rg searchTerm . -i                     " case-insensitive search
--   :Rg searchTerm . -g "*.lua"             " search only .lua files
--   :Rg searchTerm src/ -t lua              " search lua file types in src/
--   :Rg searchTerm . -i -g "*.{js,ts}"      " multiple flags
vim.api.nvim_create_user_command("Rg", function(opts)
	local args = opts.fargs
	if #args == 0 then
		vim.notify("Rg: pattern required", vim.log.levels.ERROR)
		return
	end

	local pattern = args[1]
	local path = "."
	local extra_flags = {}

	-- Parse arguments: if arg doesn't start with -, treat it as path
	for i = 2, #args do
		if args[i]:match("^%-") then
			-- This is a flag, add remaining args as flags
			for j = i, #args do
				table.insert(extra_flags, args[j])
			end
			break
		else
			-- Assume this is the path argument
			path = args[i]
		end
	end

	-- Build the ripgrep command
	local cmd_parts = { "rg", "--vimgrep" }

	-- Add extra flags
	for _, flag in ipairs(extra_flags) do
		table.insert(cmd_parts, flag)
	end

	-- Add pattern and path
	table.insert(cmd_parts, vim.fn.shellescape(pattern))
	table.insert(cmd_parts, vim.fn.shellescape(path))

	local cmd = table.concat(cmd_parts, " ")
	local results = vim.fn.system(cmd)

	-- Check for errors
	if vim.v.shell_error ~= 0 and results:match("^rg:") then
		vim.notify("Rg error: " .. results, vim.log.levels.ERROR)
		return
	end

	vim.fn.setqflist({}, " ", {
		title = "Ripgrep: " .. pattern .. " in " .. path,
		lines = vim.fn.split(results, "\n")
	})
	vim.cmd("copen")
end, { nargs = "+", complete = "file" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "<C-c>", "<cmd>bd<CR>", { buffer = true, silent = true })
		vim.keymap.set("n", "<Tab>", "mf", { buffer = true, remap = true, silent = true })
		vim.keymap.set("n", "<S-Tab>", "mF", { buffer = true, remap = true, silent = true })
		vim.keymap.set("n", "%", function()
			local dir = vim.b.netrw_curdir or vim.fn.expand("%:p:h")
			vim.ui.input({ prompt = "Enter filename: " }, function(input)
				if input and input ~= "" then
					local filepath = dir .. "/" .. input
					vim.cmd("!touch " .. vim.fn.shellescape(filepath))
					vim.api.nvim_feedkeys("<C-l>", "n", false)
				end
			end)
		end, { buffer = true, silent = true })
	end,
})

-- Run npm run complete on file save
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*",
--   callback = function()
--     local filepath = vim.fn.expand("%:p")
--     if filepath == "" then
--       return
--     end
--
--     vim.notify("Running complete on " .. vim.fn.expand("%"), vim.log.levels.INFO, { title = "npm complete" })
--
--     vim.fn.jobstart("npm run complete " .. vim.fn.shellescape(filepath), {
--       on_exit = function(_, exit_code)
--         if exit_code == 0 then
--           vim.schedule(function()
--             vim.cmd("edit")
--             vim.notify("Complete succeeded! Buffer reloaded.", vim.log.levels.INFO, { title = "npm complete" })
--           end)
--         else
--           vim.notify("Complete failed with code " .. exit_code, vim.log.levels.ERROR, { title = "npm complete" })
--         end
--       end,
--       stdout_buffered = true,
--       stderr_buffered = true,
--     })
--   end,
-- })
