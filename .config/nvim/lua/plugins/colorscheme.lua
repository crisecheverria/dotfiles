vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/mcauley-penney/techbase.nvim" },
	{ src = "https://github.com/folke/tokyonight.nvim.git" },
	{ src = "https://github.com/tahayvr/matteblack.nvim" },
	{ src = "https://github.com/ellisonleao/gruvbox.nvim" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
	{ src = "https://github.com/craftzdog/solarized-osaka.nvim" },
	{ src = "https://github.com/aymenhafeez/doric-themes.nvim" },
	{ src = "https://github.com/rodolfo-arg/gentleman-kanagawa-blur" },
	{ src = "https://github.com/Alan-TheGentleman/oldworld.nvim" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
	{ src = "https://gitlab.com/shmerl/neogotham.git" },
	{ src = "https://github.com/gnualmalki/devel.nvim" },
}, { load = true })

-- Kanagawa (wave, transparent)
require("kanagawa").setup({
	compile = false,
	undercurl = true,
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = {},
	typeStyle = {},
	transparent = true,
	dimInactive = false,
	terminalColors = true,
	colors = {
		palette = {},
		theme = {
			wave = {},
			lotus = {},
			dragon = {},
			all = {
				ui = {
					bg_gutter = "none",
					bg_sidebar = "none",
					bg_float = "none",
				},
			},
		},
	},
	overrides = function(colors)
		return {
			LineNr = { bg = "none" },
			NormalFloat = { bg = "none" },
			FloatBorder = { bg = "none" },
			FloatTitle = { bg = "none" },
			TelescopeNormal = { bg = "none" },
			TelescopeBorder = { bg = "none" },
			LspInfoBorder = { bg = "none" },
		}
	end,
	theme = "wave",
	background = {
		dark = "wave",
		light = "lotus",
	},
})

-- Kanso (zen, transparent)
require("kanso").setup({
	transparent = true,
	theme = "zen",
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		operators = {},
		types = {},
	},
})

-- All available colorschemes
local colorschemes = {
	"catppuccin-frappe",
	"catppuccin-latte",
	"catppuccin-macchiato",
	"catppuccin-mocha",
	"devel",
	"doric-beach",
	"doric-cherry",
	"doric-copper",
	"doric-dark",
	"doric-earth",
	"doric-fire",
	"doric-jade",
	"doric-light",
	"doric-marble",
	"doric-mermaid",
	"doric-oak",
	"doric-obsidian",
	"doric-pine",
	"doric-plum",
	"doric-siren",
	"doric-valley",
	"doric-water",
	"doric-wind",
	"gentleman-kanagawa-blur",
	"gruvbox",
	"gruvbox-material",
	"kanagawa",
	"kanso",
	"matteblack",
	"neogotham",
	"oldworld",
	"solarized-osaka",
	"techbase",
	"tokyonight",
	"vague",
}

local function apply_post_colorscheme()
	vim.cmd(":hi statusline guibg=NONE")
	local name = vim.g.colors_name or ""
	if name:match("^catppuccin") then
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
	end
end

local colorscheme_file = vim.fn.stdpath("data") .. "/colorscheme.txt"

local function persist_colorscheme(name)
	local file = io.open(colorscheme_file, "w")
	if file then
		file:write(name)
		file:close()
	end
end

local function load_persisted_colorscheme()
	local file = io.open(colorscheme_file, "r")
	if file then
		local name = file:read("*l")
		file:close()
		if name and name ~= "" then
			return name
		end
	end
	return nil
end

local function pick_colorscheme()
	local original = vim.g.colors_name or "default"
	local filtered = vim.list_extend({}, colorschemes)
	local selected_idx = 1
	local ns = vim.api.nvim_create_namespace("colorscheme_picker")

	-- Input buffer (filter prompt)
	local input_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[input_buf].bufhidden = "wipe"
	vim.bo[input_buf].buftype = "nofile"

	-- Results buffer
	local results_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, filtered)
	vim.bo[results_buf].modifiable = false
	vim.bo[results_buf].bufhidden = "wipe"

	local width = 30
	local results_height = math.min(#colorschemes, 30)
	local total_height = results_height + 3 -- input window + borders
	local row = math.floor((vim.o.lines - total_height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Input window (top)
	local input_win = vim.api.nvim_open_win(input_buf, true, {
		relative = "editor",
		width = width,
		height = 1,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Filter ",
		title_pos = "center",
	})

	-- Results window (below input)
	local results_win = vim.api.nvim_open_win(results_buf, false, {
		relative = "editor",
		width = width,
		height = results_height,
		row = row + 3,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Colorschemes ",
		title_pos = "center",
	})

	local function update_highlight()
		vim.api.nvim_buf_clear_namespace(results_buf, ns, 0, -1)
		if #filtered > 0 and selected_idx >= 1 and selected_idx <= #filtered then
			vim.api.nvim_buf_add_highlight(results_buf, ns, "Visual", selected_idx - 1, 0, -1)
			pcall(vim.cmd, "colorscheme " .. filtered[selected_idx])
			apply_post_colorscheme()
		end
	end

	local function update_results()
		local query = (vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)[1] or ""):lower()
		filtered = {}
		for _, name in ipairs(colorschemes) do
			if query == "" or name:lower():find(query, 1, true) then
				table.insert(filtered, name)
			end
		end
		vim.bo[results_buf].modifiable = true
		vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, filtered)
		vim.bo[results_buf].modifiable = false
		selected_idx = math.min(selected_idx, math.max(#filtered, 1))
		-- Resize results window to fit filtered list
		local new_height = math.max(math.min(#filtered, 30), 1)
		vim.api.nvim_win_set_height(results_win, new_height)
		update_highlight()
	end

	vim.cmd("startinsert")

	vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
		buffer = input_buf,
		callback = function()
			selected_idx = 1
			update_results()
		end,
	})

	local function close_picker()
		vim.cmd("stopinsert")
		if vim.api.nvim_win_is_valid(input_win) then
			vim.api.nvim_win_close(input_win, true)
		end
		if vim.api.nvim_win_is_valid(results_win) then
			vim.api.nvim_win_close(results_win, true)
		end
	end

	local function cancel()
		close_picker()
		pcall(vim.cmd, "colorscheme " .. original)
		apply_post_colorscheme()
	end

	local function confirm()
		if #filtered > 0 and selected_idx >= 1 and selected_idx <= #filtered then
			local name = filtered[selected_idx]
			close_picker()
			vim.cmd("colorscheme " .. name)
			apply_post_colorscheme()
			persist_colorscheme(name)
			vim.notify("Colorscheme: " .. name, vim.log.levels.INFO)
		end
	end

	local opts = { buffer = input_buf, noremap = true }
	local function move_down()
		selected_idx = math.min(selected_idx + 1, #filtered)
		update_highlight()
	end
	local function move_up()
		selected_idx = math.max(selected_idx - 1, 1)
		update_highlight()
	end
	vim.keymap.set({ "i", "n" }, "<C-j>", move_down, opts)
	vim.keymap.set({ "i", "n" }, "<C-n>", move_down, opts)
	vim.keymap.set({ "i", "n" }, "<Down>", move_down, opts)
	vim.keymap.set({ "i", "n" }, "<C-k>", move_up, opts)
	vim.keymap.set({ "i", "n" }, "<C-p>", move_up, opts)
	vim.keymap.set({ "i", "n" }, "<Up>", move_up, opts)
	vim.keymap.set({ "i", "n" }, "<CR>", confirm, opts)
	vim.keymap.set({ "i", "n" }, "<Esc>", cancel, opts)
	vim.keymap.set("n", "q", cancel, opts)

	update_highlight()
end

vim.keymap.set("n", "<leader>cs", pick_colorscheme, { desc = "Pick Colorscheme" })

-- Active colorscheme (load persisted choice, fall back to default)
vim.cmd("colorscheme " .. (load_persisted_colorscheme() or "catppuccin-mocha"))
apply_post_colorscheme()
