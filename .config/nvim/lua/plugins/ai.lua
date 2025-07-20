return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
    },
    config = function()
      require("codecompanion").setup({
        model = "http://localhost:11434/api/generate", -- Ollama endpoint
        model_params = { model = "deepseek-r1:7b" }, -- Custom System Prompt Model
        window = { width = 0.5, height = 0.4 }, -- Optional UI tweaks
        display = {
          action_palette = {
            width = 95,
            height = 10,
          },
          chat = {
            window = {
              layout = "vertical", -- float|vertical|horizontal|buffer
            },
          },
        },
        adapters = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "gpt-4o",
                },
              },
            })
          end,
          -- gemini = function()
          --   return require('codecompanion.adapters').extend('gemini', {
          --     schema = {
          --       model = {
          --         default = 'gemini-1.5-pro',
          --       },
          --     },
          --   })
          -- end,
          --   ollama = function()
          --     return require('codecompanion.adapters').extend('ollama', {
          --       schema = {
          --         model = {
          --           default = 'mixtral:8x22b',
          --         },
          --       },
          --     })
          --   end,
        },
        strategies = {
          chat = {
            adapter = "copilot", -- Using copilot for enhanced AI assistance
          },
          inline = {
            keymaps = {
              accept_change = {
                modes = { n = "ga" },
                description = "Accept the suggested change",
              },
              reject_change = {
                modes = { n = "gr" },
                description = "Reject the suggested change",
              },
            },
          },
        },
      })

      -- Set up keymaps
      vim.keymap.set("n", "<leader>ct", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion Chat" })
    end,
  },
}
