vim.pack.add({
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

require "gitsigns".setup({
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
})
