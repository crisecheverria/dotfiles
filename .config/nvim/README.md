# Neovim Configuration

A minimal Neovim configuration using native Neovim package management (`vim.pack.add`).

## Requirements
- Neovim >0.12

## Structure

```
~/.config/nvim/
├── init.lua                 # Main configuration entry point
├── lua/
│   ├── config/
│   │   ├── globals.lua      # Global settings and leader key
│   │   ├── options.lua      # Editor options and settings
│   │   ├── keymaps.lua      # Key mappings
│   │   └── autocmd.lua      # Auto commands
│   └── plugins/
│       ├── colorscheme.lua  # Color scheme configuration
│       ├── lsp.lua          # LSP configuration
│       ├── ai.lua           # AI tools (CodeCompanion, Copilot)
│       ├── mini.lua         # Mini.pick for file navigation
│       ├── treesitter.lua   # Syntax highlighting
│       ├── typst.lua        # Typst document support
│       ├── blink.lua        # Blink autocompletion configuration
│       ├── git.lua          # Git integration (Fugitive, Gitsigns)
│       ├── showkeys.lua     # Show pressed keys configuration
│       └── surround.lua     # Vim-surround configuration
└── README.md                # This file
```

## Plugin Management

This configuration uses Neovim's native package management with `vim.pack.add()`. No external plugin managers required.

### Installed Plugins

- **vague.nvim** - Color scheme with transparency support
- **nvim-lspconfig** - LSP configuration
- **mini.pick** - Fuzzy finder for files, buffers, and grep
- **codecompanion.nvim** - AI coding assistant (Having few issues now, but works)
- **copilot.vim** - GitHub Copilot integration  
- **nvim-treesitter** - Syntax highlighting and parsing
- **typst-preview.nvim** - Typst document preview
- **plenary.nvim** - Utility library for other plugins
- **blink.cmp** - Fast autocompletion engine with LSP support
- **vim-fugitive** - Git integration for Vim
- **gitsigns.nvim** - Git signs in the sign column
- **showkeys** - Display pressed keys on screen
- **vim-surround** - Easily change surrounding characters

## Key Features

### LSP Support
- Built-in LSP configuration for  using Mason

### Key Mappings
- Leader key: `<Space>`
- `<leader>lf` - Format buffer
- `<leader>f` - Find files
- `<leader>H` - Search help
- `<leader>g` - Live grep
- `<leader><leader>` - Switch buffers
- `<leader>e` - Open file explorer
- `<leader>t` - Open terminal in current directory
- `<leader>tc` - Open terminal and run Claude Code
- `<C-a>` - CodeCompanion actions
- `<leader>a` - Toggle CodeCompanion chat

### Auto Commands
- **Auto-format on save** - Automatically formats code when saving
- **Highlight on yank** - Briefly highlights yanked text

### Editor Options
- Line numbers with relative numbering
- Sign column always visible
- Text wrapping enabled
- 2-space tab width
- No swap files
- Rounded window borders
- System clipboard integration

## Philosophy

This configuration embraces Neovim's native capabilities:
- Leverages `vim.pack.add()` for plugin management
- Minimal dependencies and fast startup
- Clean, readable Lua configuration
- No complex plugin manager setup or lock files

The goal is a functional, fast, and maintainable Neovim setup that showcases modern Neovim features without external complexity.
