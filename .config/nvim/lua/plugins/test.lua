vim.pack.add({ "https://github.com/vim-test/vim-test" })

-- Configure test strategy (how tests are run)
-- Options: 'basic', 'neovim', 'vimterminal'
vim.g['test#strategy'] = 'neovim'

-- Optional: Configure terminal size for split
vim.g['test#neovim#term_position'] = 'vertical'

-- Optional: Make test commands verbose (useful for debugging)
-- vim.g['test#verbose'] = 1
