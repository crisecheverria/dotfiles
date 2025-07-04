return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = false, -- Keep terminal buffer when process exits
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- Custom keymap for floating terminal
    vim.keymap.set({ "n", "t" }, "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", {
      desc = "[T]oggle [F]loating terminal",
    })

    -- Custom keymap for horizontal terminal
    -- vim.keymap.set({ "n", "t" }, "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", {
    --   desc = "[T]oggle [H]orizontal terminal",
    -- })

    -- Better terminal navigation
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
