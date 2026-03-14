" =============================================================================================
" .vimrc — Modular Vim Configuration
" =============================================================================================
set nocompatible              " Use Vim defaults (not Vi)
filetype plugin indent on     " Enable filetype detection + plugins
syntax on                     " Enable syntax highlighting
let mapleader="\<Space>"

source ~/.vim/options.vim
source ~/.vim/plugins.vim
source ~/.vim/plugin-config.vim
source ~/.vim/keybinds.vim
source ~/.vim/navigation.vim
source ~/.vim/coc.vim
source ~/.vim/taskpaper.vim
source ~/.vim/sidebars.vim
source ~/.vim/persistence.vim
source ~/.vim/quit-guard.vim
