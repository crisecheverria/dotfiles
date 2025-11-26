-- Lazy load Java plugins only when opening Java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    -- Install dependencies first
    vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
    vim.pack.add({ "https://github.com/nvim-neotest/nvim-nio" })
    vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
    vim.pack.add({ "https://github.com/nvim-java/lua-async-await" })

    -- Install nvim-java and its components
    vim.pack.add({ "https://github.com/nvim-java/nvim-java-core" })
    vim.pack.add({ "https://github.com/nvim-java/nvim-java-test" })
    vim.pack.add({ "https://github.com/nvim-java/nvim-java-dap" })
    vim.pack.add({ "https://github.com/nvim-java/nvim-java-refactor" })
    vim.pack.add({ "https://github.com/nvim-java/nvim-java" })

    -- Set Java 21 home before setting up nvim-java
    local java_21_home = vim.fn.system('/usr/libexec/java_home -v 21'):gsub('\n', '')
    vim.env.JAVA_HOME = java_21_home

    require("java").setup({
      java_test = {
        enable = true,
      },
      java_debug_adapter = {
        enable = true,
      },
      jdk = {
        auto_install = false,
      },
      notifications = {
        dap = true,
      },
      -- Configure Java runtime
      root_markers = {
        'settings.gradle',
        'settings.gradle.kts',
        'pom.xml',
        'build.gradle',
        'mvnw',
        'gradlew',
        'build.gradle.kts',
      },
    })

    -- Configure jdtls after nvim-java setup
    require("lspconfig").jdtls.setup({
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-21",
                path = java_21_home,
                default = true
              }
            }
          }
        }
      }
    })
  end,
  once = true,  -- Only run this once
})
