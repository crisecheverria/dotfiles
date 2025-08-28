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
    -- Set up buffer-local keymaps for LSP
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_definition) then
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Go to Definition' })
    end
  end,
})

-- Activate nvim-treesitter
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'javascript', 'typescrypt', 'python', 'rust', 'lua', 'html' },
  callback = function()
    -- syntax highlighting, provided by Neovim
    vim.treesitter.start()
    -- folds, provided by Neovim
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- indentation, provided by nvim-treesitter
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})


-- Ripgrep with quickfix list
vim.api.nvim_create_user_command("Rg", function(opts)
  local query = opts.args
  local escaped_query = vim.fn.shellescape(query)
  local results = vim.fn.system("rg --vimgrep " .. escaped_query)
  vim.fn.setqflist({}, " ", { title = "Ripgrep Search", lines = vim.fn.split(results, "\n") })
  vim.cmd("copen")
end, { nargs = 1 })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.keymap.set('n', '<C-c>', '<cmd>bd<CR>', { buffer = true, silent = true })
    vim.keymap.set('n', '<Tab>', 'mf', { buffer = true, remap = true, silent = true })
    vim.keymap.set('n', '<S-Tab>', 'mF', { buffer = true, remap = true, silent = true })
    vim.keymap.set('n', '%', function()
      local dir = vim.b.netrw_curdir or vim.fn.expand('%:p:h')
      vim.ui.input({ prompt = 'Enter filename: ' }, function(input)
        if input and input ~= '' then
          local filepath = dir .. '/' .. input
          vim.cmd('!touch ' .. vim.fn.shellescape(filepath))
          vim.api.nvim_feedkeys('<C-l>', 'n', false)
        end
      end)
    end, { buffer = true, silent = true })
  end
})
