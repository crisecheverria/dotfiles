vim.pack.add({ "https://github.com/folke/sidekick.nvim" }, { load = true })

require("sidekick").setup({
  nes = {
    enabled = false
  }
})
