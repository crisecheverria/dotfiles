-- Global keymaps (all modes).
-- Contributes: keymaps, unbinds.
-- Includes: jj-escape, leader bindings for find/grep/buffer/test/run/
-- lazygit/colorscheme, window navigation
-- (<C-hjkl> and <M-arrows>), line-move (<a-j/k>), visual `s` surround.
-- Bracket/quote autopairs live in nvim-autopairs (lua/plugins.lua).
-- Disabling this module leaves you with only Neovim defaults.

local utils = require("utils")
local discovery = require("tools/api-discovery")

local function surround()
	local ok, left = pcall(vim.fn.getcharstr)
	if not ok or left == "\27" then
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
		-- Bracket/quote autopairs and <CR>-expansion handled by nvim-autopairs.
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
			"<cmd>CloseFloatingTerminal<cr>",
			{ noremap = true, silent = true, desc = "Close floating terminal" },
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
		{
			{ "n" },
			"<leader>x",
			function()
				vim.diagnostic.setqflist({ open = true })
			end,
			{ desc = "Diagnostics → quickfix" },
		},
		{ { "n" }, "<leader>gg", "<cmd>Lazygit<cr>", { desc = "open lazygit" } },
		{ { "n" }, "<leader>u", "<cmd>Undotree<cr>", { desc = "Toggle undo tree" } },
		{ { "n" }, "<leader>df", ":DiffTool ", { desc = "DiffTool <left> <right>" } },
		{
			{ "n" },
			"<leader>f",
			function()
				require("fzf-lua").files()
			end,
			{ desc = "Find files" },
		},
		{
			{ "n" },
			"<leader>g",
			function()
				require("fzf-lua").live_grep({ prompt = "Grep> " })
			end,
			{ desc = "Live grep" },
		},
		{
			{ "n" },
			"<leader>G",
			function()
				require("fzf-lua").live_grep({
					prompt = "Grep (all)> ",
					no_ignore = true,
					follow = true,
				})
			end,
			{ desc = "Live grep (include node_modules)" },
		},
		{ { "n" }, "<leader>cs", "<cmd>ColorPicker<cr>", { desc = "colorscheme picker" } },
		{
			{ "n" },
			"<leader>rt",
			"<cmd>RunTest<cr>",
			{ desc = "run test for current file" },
		},
		{
			{ "n" },
			"<leader>rr",
			"<cmd>RunFile<cr>",
			{ desc = "build & run current file" },
		},

		{
			{ "n" },
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			{ desc = "Toggle file explorer" },
		},
		-- LSP-free navigation: tags (`gd`) and grep-as-references (`gr`).
		-- `gd` -> g<C-]> uses :tjump so multiple matches show a chooser.
		-- Generate tags with `ctags -R .` at the project root.
		{ { "n" }, "gd", "g<C-]>", { desc = "Go to definition (tags)" } },
		{ { "n" }, "gr", ":Grep <C-r><C-w><cr>", { desc = "Find references (grep cword)" } },
		{
			{ "n" },
			"<leader>rn",
			[[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]],
			{ desc = "rename: substitute word under cursor (buffer)" },
		},
		{
			{ "x" },
			"<leader>rn",
			[["zy:%s/\V<C-r>z//gI<Left><Left><Left>]],
			{ desc = "rename: substitute selection (buffer)" },
		},
		{ { "n" }, "<leader>b", ":buffer<space>", { desc = "switch buffer" } },
		{
			{ "n" },
			"<leader><leader>",
			function()
				Snacks.picker.buffers()
			end,
			{ desc = "list buffers" },
		},
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
		{
			{ "n" },
			"<leader>s",
			discovery.module_api_search,
			{ noremap = true, silent = true, desc = "API Discovery" },
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
	},
	unbinds = {
		{ { "n", "v" }, "g0" },
		{ { "n", "v" }, "g^" },
		{ { "n", "v" }, "g$" },
		{ { "n", "v" }, "gq" },
	},
}
