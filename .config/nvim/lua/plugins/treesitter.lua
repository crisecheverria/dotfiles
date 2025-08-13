vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require('nvim-treesitter').setup({ ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }, auto_install = true, sync_install = false, highlight = { enable = true, }, })
