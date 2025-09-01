local map = vim.keymap.set
map('n', '<leader>lf', "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Format Buffer", silent = true })
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition", silent = true })
map('n', '<leader>f', ":Pick files<CR>", { desc = "Find File", silent = true })
map('n', '<leader>H', ":Pick help<CR>", { desc = "Help", silent = true })
map('n', '<leader>g', ":Pick grep_live<CR>", { desc = "Grep", silent = true })
map('n', '<leader>r', ":Rg ", { desc = "Rip Grep" })
map('n', '<leader>sw', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('Rg ' .. word)
end, { desc = "Rip Grep current word", silent = true })
map('n', '<leader><leader>', ":Pick buffers<CR>", { desc = "Buffers", silent = true })
map('n', '<leader>e', ":Ex<CR>", { desc = "File Explorer", silent = true })
map('n', '<leader>v', ":vsplit<CR>", { desc = "Vertical Split", silent = true })
map('n', '<leader>h', ":split<CR>", { desc = "Horizontal Split", silent = true })
map('n', '<leader>w', ":w<CR>", { desc = "Save", silent = true })
map('n', '<leader>q', ":q<CR>", { desc = "Quit", silent = true })
map("n", "<leader>x", vim.diagnostic.setloclist, { desc = "Diagnostics", silent = true })
map("n", "<leader>pu", '<cmd>lua vim.pack.update()<CR>', { desc = "Update plugins", silent = true })

-- Terminal keymaps
map("n", "<leader>t", function()
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { noremap = true, silent = true, desc = "Open Terminal" }) -- Open terminal

-- Run claude code in terminal
map("n", "<leader>tc", function()
  vim.cmd("terminal")
  vim.cmd("startinsert")
  vim.api.nvim_feedkeys("claude\n", "t", false)
end, { noremap = true, silent = true, desc = "Open Claude" }) -- Run claude code

-- Copy relative path of open buffer
map("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
  print("Copied relative path: " .. vim.fn.expand("%"))
end, { desc = "Copy relative file path" })
