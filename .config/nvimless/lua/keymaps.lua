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

return {
	keymaps = {
		-- Insert mode
		{ { "i" }, "jj", "<esc>", { desc = "Exit insert mode" } },
		-- Terminal mode
		{ { "n" }, "<C-h>", "<C-w>h", { desc = "Move to left window" } },
		{ { "n" }, "<C-l>", "<C-w>l", { desc = "Move to right window" } },
		{ { "n" }, "<C-j>", "<C-w>j", { desc = "Move to window below" } },
		{ { "n" }, "<C-k>", "<C-w>k", { desc = "Move to window above" } },
		-- normal mode
		{ { "n", "t" }, "<c-;>", "<cmd>AiCli<cr>", { desc = "toggle claude code terminal" } },
		{ { "n" }, "<leader>t", "<cmd>FloatingTerminal<cr>", { noremap = true, silent = true, desc = "Toggle floating terminal" } },
		{ { "t" }, "<Esc>", "<cmd>CloseFloatingTerminal<cr>", { noremap = true, silent = true, desc = "Close floating terminal" } },
		{ { "n" }, "<esc>", "<esc><cmd>noh<cr>", { silent = true, desc = "clear search highlight" } },
		{ { "n" }, "x", betterdelete(true), { expr = true, desc = "delete char (void register)" } },
		{ { "n" }, "<leader>x", vim.diagnostic.setloclist, { desc = "Open diagnostic list" } },
		{ { "n" }, "<leader>cs", "<cmd>ColorPicker<cr>", { desc = "colorscheme picker" } },
		{ { "n" }, "<leader>rt", "<cmd>RunTest<cr>", { desc = "run test for current file" } },
		{ { "n" }, "<leader>b", ":buffer<space>", { desc = "switch buffer" } },
		{ { "n" }, "<leader><leader>", "<cmd>buffers<cr>", { desc = "list buffers" } },
		{ { "n" }, "<leader>cp",
			function()
				local path = vim.fn.expand("%:.")
				vim.fn.setreg("+", path)
				print("file:", path)
			end,
			{ desc = "Copy file path to clipboard" }
		},
		-- visual mode
		{ { "v" }, "r", '"_dp', { desc = "replace selection without yanking" } },
		{ { "v" }, "s", surround, { expr = true, desc = "surround selection" } },
		{ { "n" }, "<a-j>", ":m .+1<cr>==", { desc = "move line down" } },
		{ { "n" }, "<a-k>", ":m .-2<cr>==", { desc = "move line up" } },
		{ { "v" }, "<a-j>", ":m '>+1<cr>gv=gv", { desc = "move selection down" } },
		{ { "v" }, "<a-k>", ":m '<-2<cr>gv=gv", { desc = "move selection up" } },
		-- normal & visual mode
		{ { "n", "v" }, "d", '"_d', { desc = "delete to void register" } },
		{ { "n", "v" }, "gh", "^", { desc = "go to first non-blank char" } },
		{ { "n", "v" }, "gj", "gg0", { desc = "go to last line" } },
		{ { "n", "v" }, "gk", "ggg0", { desc = "go to first line" } },
		{ { "n", "v" }, "gl", "$", { desc = "go to end of line" } },
		-- { { "n", "v" }, "&", "j", { desc = "join lines" } },
		{ { "n", "v" }, "=", "gq", { desc = "format/wrap lines" } },
		{ { "n", "v" }, "m", "%", { desc = "jump to matching bracket" } },
	},
	unbinds = {
		{ { "n", "v" }, "gg" },
		{ { "n", "v" }, "g" },
		{ { "n", "v" }, "g0" },
		{ { "n", "v" }, "g^" },
		{ { "n", "v" }, "g$" },
		{ { "n", "v" }, "gq" },
	},
}
