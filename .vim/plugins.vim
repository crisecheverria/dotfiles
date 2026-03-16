" =============================================================================================
" Plugin Manager (vim-plug)
" =============================================================================================
call plug#begin('~/.vim/plugged')

" Essentials
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'yggdroot/indentline'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'machakann/vim-highlightedyank'

" Navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
Plug 'vim-airline/vim-airline'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

"Start Screen
Plug 'mhinz/vim-startify'

" To Do Lists
Plug 'dkarter/bullets.vim'
Plug 'davidoc/taskpaper.vim'

"AI
Plug 'github/copilot.vim'
Plug 'madox2/vim-ai'

"Color Scheme
Plug 'ap/vim-css-color'
Plug 'c9rgreen/vim-colors-modus'
Plug 'ghifarit53/tokyonight-vim'

call plug#end()
