vim.pack.add({ "https://github.com/crisecheverria/ai-cli.nvim" }, { load = true })

require("ai-cli").setup({
  provider = "claude",
  terminal_cmd = "claude",
  log_level = "info",
  terminal = {
    split_side = "right",
    split_width_percentage = 0.4,
    auto_close = true,
  },
  diff = {
    accept_key = "ga",
    reject_key = "gr",
  },
})
