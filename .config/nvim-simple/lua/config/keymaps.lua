local map = vim.keymap.set
map('n', '<leader>lf', vim.lsp.buf.format) -- Format buffer
map('n', '<leader>f', ":Pick files<CR>")   -- Mini.pick Find File
map('n', '<leader>H', ":Pick help<CR>")    -- Documentation
map('n', '<leader>g', ":Pick grep_live<CR>")
map('n', '<leader><leader>', ":Pick buffers<CR>")

local opts = { silent = true }
map("n", "<leader>x", vim.diagnostic.open_float, opts)
map("n", "<leader>q", vim.diagnostic.setloclist, opts)

-- CodeCompanion keymaps
map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
