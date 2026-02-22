-- Neo-tree dependencies
vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" }, { load = true })
vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" }, { load = true })
vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim" }, { load = true })

-- Neo-tree main plugin
vim.pack.add({ "https://github.com/nvim-neo-tree/neo-tree.nvim" }, { load = true })

require("neo-tree").setup({
	close_if_last_window = false,
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,
	default_component_configs = {
		indent = {
			indent_size = 2,
			padding = 1,
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
			highlight = "NeoTreeIndentMarker",
		},
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "󰜌",
			default = "*",
		},
		git_status = {
			symbols = {
				added = "+",
				modified = "u",
				deleted = "✖",
				renamed = "󰁕",
				untracked = "",
				ignored = "",
				unstaged = "󰄱",
				staged = "󰄲",
				conflict = "-",
			},
		},
	},
	window = {
		position = "left",
		width = 40,
		mapping_options = {
			noremap = true,
			nowait = true,
		},
		mappings = {
			["<space>"] = {
				"toggle_node",
				nowait = false,
			},
			["<2-LeftMouse>"] = "open",
			["<cr>"] = "open",
			["<esc>"] = "cancel",
			["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
			["l"] = "focus_preview",
			["S"] = "open_split",
			["s"] = "open_vsplit",
			["t"] = "open_tabnew",
			["w"] = "open_with_window_picker",
			["C"] = "close_node",
			["z"] = "close_all_nodes",
			["a"] = {
				"add",
				config = {
					show_path = "none",
				},
			},
			["A"] = "add_directory",
			["d"] = "delete",
			["r"] = "rename",
			["y"] = "copy_to_clipboard",
			["x"] = "cut_to_clipboard",
			["p"] = "paste_from_clipboard",
			["c"] = "copy",
			["m"] = "move",
			["q"] = "close_window",
			["R"] = "refresh",
			["?"] = "show_help",
			["<"] = "prev_source",
			[">"] = "next_source",
			["i"] = "show_file_details",
		},
	},
	filesystem = {
		filtered_items = {
			visible = false,
			hide_dotfiles = false,
			hide_gitignored = false,
			hide_hidden = true,
			hide_by_name = {},
			hide_by_pattern = {},
			always_show = {},
			never_show = {},
		},
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		group_empty_dirs = false,
		hijack_netrw_behavior = "open_default",
		use_libuv_file_watcher = false,
		window = {
			mappings = {
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["H"] = "toggle_hidden",
				["/"] = "fuzzy_finder",
				["D"] = "fuzzy_finder_directory",
				["#"] = "fuzzy_sorter",
				["f"] = "filter_on_submit",
				["<c-x>"] = "clear_filter",
				["[g"] = "prev_git_modified",
				["]g"] = "next_git_modified",
				["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["og"] = { "order_by_git_status", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
			},
		},
	},
	buffers = {
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		group_empty_dirs = true,
		show_unloaded = true,
		window = {
			mappings = {
				["bd"] = "buffer_delete",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
			},
		},
	},
	git_status = {
		window = {
			position = "float",
			mappings = {
				["A"] = "git_add_all",
				["gu"] = "git_unstage_file",
				["ga"] = "git_add_file",
				["gr"] = "git_revert_file",
				["gc"] = "git_commit",
				["gp"] = "git_push",
				["gg"] = "git_commit_and_push",
				["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
			},
		},
	},
})

-- Keymaps
vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { noremap = true, silent = true, desc = "Toggle Neo-tree" })
vim.keymap.set("n", "<leader>o", ":Neotree focus<CR>", { noremap = true, silent = true, desc = "Focus Neo-tree" })
vim.keymap.set(
	"n",
	"<leader>gs",
	":Neotree float git_status<CR>",
	{ noremap = true, silent = true, desc = "Neo-tree Git Status" }
)
