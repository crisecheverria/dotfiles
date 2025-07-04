-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Ripgrep with quickfix list
vim.api.nvim_create_user_command("Rg", function(opts)
  local query = opts.args
  local escaped_query = vim.fn.shellescape(query)
  local results = vim.fn.system("rg --vimgrep " .. escaped_query)
  vim.fn.setqflist({}, " ", { title = "Ripgrep Search", lines = vim.fn.split(results, "\n") })
  vim.cmd("copen")
end, { nargs = 1 })

-- Keymap to open a terminal
vim.keymap.set("n", "<leader>st", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  -- Get the current window ID and set its height
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win_id, 15)
end, { desc = "[S]tart [T]erminal" })

-- Example of runing custom commands into terminal.
-- Could be used for npm build, npm start, etc.

vim.keymap.set("n", "<leader>nb", function()
  vim.cmd.vnew()
  vim.cmd("term npm run build")
end, { desc = "[N]pm [B]uild" })

-- Copy relative path of open buffer
vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
  print("Copied relative path: " .. vim.fn.expand("%"))
end, { desc = "Copy relative file path" })

-- Add classic window navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Map Ctrl+s to save
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save file" })
