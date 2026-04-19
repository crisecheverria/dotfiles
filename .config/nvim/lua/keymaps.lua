local utils = require("utils")

local function surround()
	local ok, left = pcall(vim.fn.getcharstr)
	if not ok or char == "\27" then
		return ""
	end
	local right = utils.v_pairs[left]
	right = right or left

	return string.format([[c%s<C-R>"%s<Esc>]], left, right)
end

local function betterdelete(should_void_register)
	return function()
		local keys = vim.fn.getline("."):len() == 0 and "vd<Esc>" or "x"
		if not should_void_register then
			return keys
		end
		return '"_' .. keys
	end
end

local function char_after_cursor()
	local col = vim.fn.col(".")
	local line = vim.fn.getline(".")
	return line:sub(col, col)
end

local function auto_close(close)
	return function()
		if char_after_cursor() == close then
			return "<Right>"
		end
		return close
	end
end

local function auto_quote(quote)
	return function()
		if char_after_cursor() == quote then
			return "<Right>"
		end
		return quote .. quote .. "<Left>"
	end
end

local function auto_cr()
	local col = vim.fn.col(".")
	local line = vim.fn.getline(".")
	local before = line:sub(col - 1, col - 1)
	local after = line:sub(col, col)
	if utils.v_pairs[before] == after then
		return "<CR><Esc>==O"
	end
	return "<CR>"
end

local expr_rk = { expr = true, replace_keycodes = true }

return {
	keymaps = {
		-- Insert mode
		{ { "i" }, "jj", "<esc>", { desc = "Exit insert mode" } },
		-- Auto-close pairs
		{ { "i" }, "(", "()<Left>", { desc = "auto close ()" } },
		{ { "i" }, "[", "[]<Left>", { desc = "auto close []" } },
		{ { "i" }, "{", "{}<Left>", { desc = "auto close {}" } },
		{
			{ "i" },
			")",
			auto_close(")"),
			vim.tbl_extend("force", expr_rk, { desc = "skip over )" }),
		},
		{
			{ "i" },
			"]",
			auto_close("]"),
			vim.tbl_extend("force", expr_rk, { desc = "skip over ]" }),
		},
		{
			{ "i" },
			"}",
			auto_close("}"),
			vim.tbl_extend("force", expr_rk, { desc = "skip over }" }),
		},
		{
			{ "i" },
			'"',
			auto_quote('"'),
			vim.tbl_extend("force", expr_rk, { desc = 'auto close "' }),
		},
		{
			{ "i" },
			"'",
			auto_quote("'"),
			vim.tbl_extend("force", expr_rk, { desc = "auto close '" }),
		},
		{
			{ "i" },
			"`",
			auto_quote("`"),
			vim.tbl_extend("force", expr_rk, { desc = "auto close `" }),
		},
		{
			{ "i" },
			"<CR>",
			auto_cr,
			vim.tbl_extend("force", expr_rk, { desc = "expand pair on enter" }),
		},
		-- normal mode
		{
			{ "n" },
			"<leader>t",
			"<cmd>FloatingTerminal<cr>",
			{ noremap = true, silent = true, desc = "Toggle floating terminal" },
		},
		{
			{ "t" },
			"<Esc>",
			function()
				if vim.bo.filetype == "ai-cli-terminal" then
					local keys = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
					vim.api.nvim_feedkeys(keys, "n", false)
				else
					vim.cmd("CloseFloatingTerminal")
				end
			end,
			{ noremap = true, silent = true, desc = "Close floating terminal (pass Esc to ai-cli)" },
		},
		{
			{ "n" },
			"<esc>",
			"<esc><cmd>noh<cr>",
			{ silent = true, desc = "clear search highlight" },
		},
		{
			{ "n" },
			"x",
			betterdelete(true),
			{ expr = true, desc = "delete char (void register)" },
		},
		{ { "n" }, "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic list" } },
		{ { "n" }, "<leader>gg", "<cmd>Lazygit<cr>", { desc = "open lazygit" } },
		{
			{ "n" },
			"<leader>f",
			function()
				require("fff").find_files()
			end,
			{ desc = "Find files" },
		},
		{
			{ "n" },
			"<leader>s",
			function()
				require("fff").live_grep()
			end,
			{ desc = "Live grep" },
		},
		{ { "n" }, "<leader>cs", "<cmd>ColorPicker<cr>", { desc = "colorscheme picker" } },
		{
			{ "n" },
			"<leader>rt",
			"<cmd>RunTest<cr>",
			{ desc = "run test for current file" },
		},
		{ { "n" }, "<leader>b", ":buffer<space>", { desc = "switch buffer" } },
		{ { "n" }, "<leader><leader>", "<cmd>buffers<cr>", { desc = "list buffers" } },
		{ { "n" }, "<M-Left>", "<C-w>h", { desc = "move to left window" } },
		{ { "n" }, "<M-Right>", "<C-w>l", { desc = "move to right window" } },
		{ { "n" }, "<M-Up>", "<C-w>k", { desc = "move to upper window" } },
		{ { "n" }, "<M-Down>", "<C-w>j", { desc = "move to lower window" } },
		{ { "n" }, "<C-h>", "<C-w>h", { desc = "move to left window" } },
		{ { "n" }, "<C-l>", "<C-w>l", { desc = "move to right window" } },
		{ { "n" }, "<C-k>", "<C-w>k", { desc = "move to upper window" } },
		{ { "n" }, "<C-j>", "<C-w>j", { desc = "move to lower window" } },
		{
			{ "n" },
			"<leader>cp",
			function()
				local path = vim.fn.expand("%:.")
				vim.fn.setreg("+", path)
				print("file:", path)
			end,
			{ desc = "Copy file path to clipboard" },
		},
		-- visual mode
		{
			{ "v" },
			"r",
			'"_dp',
			{ desc = "replace selection without yanking" },
		},
		{ { "n", "x", "o" }, "f", require("jump").start, { desc = "jump" } },
		{
			{ "v" },
			"s",
			surround,
			{ expr = true, desc = "surround selection" },
		},
		{ { "n" }, "<a-j>", ":m .+1<cr>==", { desc = "move line down" } },
		{ { "n" }, "<a-k>", ":m .-2<cr>==", { desc = "move line up" } },
		{ { "v" }, "<a-j>", ":m '>+1<cr>gv=gv", { desc = "move selection down" } },
		{ { "v" }, "<a-k>", ":m '<-2<cr>gv=gv", { desc = "move selection up" } },
		-- normal & visual mode
		{ { "n", "v" }, "d", '"_d', { desc = "delete to void register" } },
		{ { "n", "v" }, "gh", "^", { desc = "go to first non-blank char" } },
		{ { "n", "v" }, "gj", "G0", { desc = "go to last line" } },
		{ { "n", "v" }, "gk", "gg0", { desc = "go to first line" } },
		{ { "n", "v" }, "gl", "$", { desc = "go to end of line" } },
		-- { { "n", "v" }, "&", "j", { desc = "join lines" } },
		{ { "n", "v" }, "=", "gq", { desc = "format/wrap lines" } },
		{ { "n", "v" }, "m", "%", { desc = "jump to matching bracket" } },
		{ { "n", "v" }, "<Space>", ":", { desc = "command-line mode" } },
		{ { "n", "v" }, ":", ",", { desc = "reverse f/t" } },
		-- llama.vim
		{
			{ "v" },
			"<leader>li",
			":LlamaInstruct<cr>",
			{ desc = "Llama instruct (ask about selection)" },
		},
		{ { "n" }, "<leader>lr", ":LlamaInstruct<cr>", { desc = "Llama rerun instruction" } },
		{ { "n" }, "<leader>lt", "<cmd>LlamaToggle<cr>", { desc = "Llama toggle on/off" } },
		{ { "n" }, "<leader>lf", "<cmd>LlamaToggleAutoFim<cr>", { desc = "Llama toggle auto-FIM" } },
		{ { "n" }, "<leader>ld", "<cmd>LlamaDebugToggle<cr>", { desc = "Llama toggle debug" } },
		-- claudecode.nvim
		{ { "n" }, "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" } },
		{ { "n" }, "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" } },
		{ { "n" }, "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" } },
		{ { "n" }, "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" } },
		{ { "n" }, "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" } },
		{ { "n" }, "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer to Claude" } },
		{ { "v" }, "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" } },
		{ { "n" }, "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff" } },
		{ { "n" }, "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff" } },
	},
	unbinds = {
		{ { "n", "v" }, "g0" },
		{ { "n", "v" }, "g^" },
		{ { "n", "v" }, "g$" },
		{ { "n", "v" }, "gq" },
	},
}
