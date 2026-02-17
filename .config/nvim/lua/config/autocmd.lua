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
		-- Check if parser is available before starting treesitter
		local lang = vim.bo.filetype
		if vim.treesitter.language.get_lang(lang) then
			local ok = pcall(vim.treesitter.start)
			if ok then
				-- folds, provided by Neovim
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				-- indentation, provided by nvim-treesitter
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end
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
	table.insert(cmd_parts, pattern)
	table.insert(cmd_parts, path)

	vim.notify("Rg: searching...", vim.log.levels.INFO)

	vim.system(cmd_parts, { text = true }, function(obj)
		vim.schedule(function()
			if obj.code ~= 0 and obj.stderr and obj.stderr:match("^rg:") then
				vim.notify("Rg error: " .. obj.stderr, vim.log.levels.ERROR)
				return
			end

			local results = obj.stdout or ""
			vim.fn.setqflist({}, " ", {
				title = "Ripgrep: " .. pattern .. " in " .. path,
				lines = vim.fn.split(results, "\n"),
			})
			vim.cmd("copen")
		end)
	end)
end, { nargs = "+", complete = "file" })

-- Command to show intro screen
vim.api.nvim_create_user_command("Intro", function()
	vim.cmd("enew")
	vim.cmd("intro")
end, { desc = "Show Neovim intro screen" })

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

-- Ensure intro screen is enabled by removing 'I' flag from shortmess
vim.opt.shortmess:remove("I")

-- Command to open file in Google Chrome
-- Usage: :Chrome [filename]
-- If no filename provided, opens current file
vim.api.nvim_create_user_command("Chrome", function(opts)
	local filepath
	if opts.args and opts.args ~= "" then
		-- Use provided filename, expand to absolute path if relative
		filepath = vim.fn.fnamemodify(opts.args, ":p")
	else
		-- Use current file if no argument provided
		filepath = vim.fn.expand("%:p")
	end
	vim.cmd('!open -a "Google Chrome" ' .. vim.fn.shellescape(filepath))
end, { nargs = "?", complete = "file" })
