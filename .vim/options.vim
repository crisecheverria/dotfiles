" =============================================================================================
" Basic Settings
" =============================================================================================
highlight ExtraWhitespace ctermbg=red guibg=red

set number                    " Show absolute line numbers
set relativenumber            " Show relative numbers (great for motions)
set cursorline                " Highlight current line
set showmatch                 " Highlight matching bracket
set ignorecase smartcase      " Case-insensitive search unless uppercase used
set hlsearch                  " Highlight search results
set incsearch                 " Live search results while typing
set tabstop=4                 " Tabs are 4 spaces
set shiftwidth=4              " Indent by 4 spaces
set expandtab                 " Use spaces instead of tabs
set autoindent                " Auto-indent new lines
set clipboard=unnamed         " Use system clipboard (macOS uses * register)
set hidden                    " Allow switching buffers without saving
set mouse=a                   " Enable mouse support
set autoread
set re=0                     " Fix redrawing issues
set noswapfile               " Disable swap files

set background=dark
" Use truecolor if available
if has('termguicolors')
  set termguicolors
endif
" Disable background-color erase to prevent white gaps on first draw
set t_ut=

" Cursor shape: thin bar in insert mode, block in normal mode
let &t_SI = "\e[6 q"  " steady bar in insert
let &t_SR = "\e[4 q"  " steady underline in replace
let &t_EI = "\e[2 q"  " steady block in normal

" Sessions
" --- Session behavior (workspace resume when no args) ---
" Tune what sessions store (sane defaults)
set sessionoptions=blank,buffers,curdir,help,tabpages,winsize,folds,terminal
