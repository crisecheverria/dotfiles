vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" } })

require 'nvim-treesitter'.install { 'rust', 'javascript', 'typescript', 'python', 'go', 'rust', 'lua', 'html' }
