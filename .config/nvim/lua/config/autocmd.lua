-- Autoformat on save (:w)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("erock.cfg", { clear = true }),
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- LSP configuration
-- Use default LSP global keymaps:
-- gd (Go to Definition)
-- grn (vim.lsp.buf.rename())
-- gra (vim.lsp.buf.code_action())
-- grr (vim.lsp.buf.references())
-- gri (vim.lsp.implementation())
-- grt (vim.lsp.buf.type_definition())
-- gO (vim.lsp.buf.signature_help())
-- K (vim.lsp.buf.hover())
--
-- Also have native autocompletion with vim.lsp.completion.enable
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      vim.keymap.set('i', '<C-Space>', function()
        vim.lsp.completion.get()
      end)
    end
  end,
})
