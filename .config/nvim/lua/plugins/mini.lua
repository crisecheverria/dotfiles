vim.pack.add({"https://github.com/echasnovski/mini.pick" })

require "mini.pick".setup({
  source = {
    grep_live = function()
      local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      local cwd = (vim.fn.isdirectory(git_root) == 1) and git_root or vim.fn.getcwd()
      return require('mini.pick').builtin.grep_live({}, { source = { cwd = cwd } })
    end
  }
})

