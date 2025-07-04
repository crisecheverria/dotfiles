# Dotfiles

Personal configuration files for development environment.

## Overview

This repository contains configuration files for various applications and tools, managed through symlinks for seamless updates.

## Contents

- **`.config/`** - Application configuration directory containing:
  - **neovim** - LazyVim configuration
  - **zed** - Editor settings and keymaps
  - **ghostty** - Terminal configuration
  - **atuin** - Shell history sync
  - **fish** - Shell configuration
  - **raycast** - Productivity extensions
  - **yabai** - Window manager
  - And many more...

- **`.vimrc`** - Vim configuration file

## Setup

The configuration files are symlinked to their expected locations:

```bash
~/.config -> ~/dotfiles/.config
~/.vimrc -> ~/dotfiles/.vimrc
```

## Usage

1. Clone this repository to `~/dotfiles`
2. Create symlinks:
   ```bash
   ln -s ~/dotfiles/.config ~/.config
   ln -s ~/dotfiles/.vimrc ~/.vimrc
   ```

## Adding New Configurations

New configurations added to `~/.config/` will automatically be tracked in this repository due to the symlink setup.

## Excluded Files

The following files are excluded via `.gitignore`:
- Shell configurations (`.zshrc`, `.bashrc`)
- Git configuration (`.gitconfig`)
- System files (`.DS_Store`, swap files)