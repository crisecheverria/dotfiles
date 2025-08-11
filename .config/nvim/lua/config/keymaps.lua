local map = vim.keymap.set
map('n', '<leader>lf', vim.lsp.buf.format) -- Format buffer
map('n', '<leader>f', ":Pick files<CR>")   -- Mini.pick Find File
map('n', '<leader>H', ":Pick help<CR>")    -- Documentation
map('n', '<leader>g', ":Pick grep_live<CR>")
map('n', '<leader><leader>', ":Pick buffers<CR>")
map('n', '<leader>e', ":Ex<CR>")           -- Open Explorer

local opts = { silent = true }
map("n", "<leader>x", vim.diagnostic.setloclist, opts)

-- Terminal keymaps
map("n", "<leader>t", function()
  local buf_dir = vim.fn.expand("%:p:h")
  if buf_dir and buf_dir ~= "" then
    vim.cmd("lcd " .. buf_dir)
  end
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { noremap = true, silent = true })

-- Run claude code in terminal
map("n", "<leader>tc", function()
  local buf_dir = vim.fn.expand("%:p:h")
  if buf_dir and buf_dir ~= "" then
    vim.cmd("lcd " .. buf_dir)
  end
  vim.cmd("terminal")
  vim.cmd("startinsert")
  vim.api.nvim_feedkeys("claude\n", "t", false)
end, { noremap = true, silent = true }) -- Run claude code

-- CodeCompanion keymaps
map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Copy relative path of open buffer
map("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
  print("Copied relative path: " .. vim.fn.expand("%"))
end, { desc = "Copy relative file path" })
