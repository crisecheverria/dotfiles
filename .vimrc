vim9script
source $VIMRUNTIME/defaults.vim
language messages en_US
colorscheme zaibatsu
g:mapleader = ' '
noremap <C-e> g_
nnoremap j gj
nnoremap k gk
nnoremap K i<CR><Esc>
nnoremap gd <C-]>
nnoremap <C-q> :q<CR>
nnoremap <C-s> :%s/\s\+$//e<bar>w<CR>
nnoremap <C-d> <C-d>zz
vnoremap <C-d> <C-d>zz
nnoremap <C-f> <C-u>zz
vnoremap <C-f> <C-u>zz
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv
set autoread belloff=all background=dark termguicolors
set complete=.,w,b,u,t completeopt=menuone,longest,preview
set cursorline cursorcolumn textwidth=100 signcolumn=yes
set expandtab softtabstop=4 tabstop=4 shiftwidth=4 smarttab autoindent breakindent
set grepformat=%f:%l:%c:%m,%f:%l:%m
set hlsearch ignorecase smartcase infercase
set iskeyword=@,48-57,_,192-255,-,#
set nofoldenable noswapfile nowrap
set number relativenumber list listchars=tab:-->,trail:~,nbsp:␣
set undofile undodir=expand('$HOME/.vim/undo/')
set viminfofile=$HOME/.vim/.viminfo wildignorecase path+=**
set wildoptions=pum pumheight=50
# Fix redraw timeout exceeded error for typescript files
set re=0

if executable('clang-format')
    autocmd FileType c,cpp,objc,objcpp
    \ | nnoremap <buffer> <leader>fmt :update<CR>:silent !clang-format -i %:p<CR>:e!<CR>
endif
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --hidden grepformat=%f:%l:%c:%m
    nnoremap <leader>gg :silent! grep <C-R><C-W> .<CR>:copen<CR>:redraw!<CR>
endif
const vimplug = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if has('unix') && empty(glob('~/.vim/autoload/plug.vim'))
    execute 'silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs ' .. vimplug
elseif (has('win32') || has('win64')) && empty(glob('$HOME/vimfiles/autoload/plug.vim'))
    execute 'silent !powershell -command "iwr -useb ' .. vimplug
        .. ' | ni $HOME/vimfiles/autoload/plug.vim -Force"'
endif
call plug#begin()
Plug 'https://github.com/tpope/vim-commentary'         # Comment out
Plug 'https://github.com/tpope/vim-fugitive'           # Git integration
Plug 'https://github.com/tpope/vim-surround'           # Surroud word with char
Plug 'https://github.com/tpope/vim-unimpaired'         # Efficient keymaps
Plug 'https://github.com/godlygeek/tabular'            # Text alignment
Plug 'https://github.com/preservim/nerdtree'           # File browser
Plug 'https://github.com/skywind3000/asyncrun.vim'     # Asynchronously run
Plug 'https://github.com/yegappan/lsp'                 # LSP support
Plug 'https://github.com/github/copilot.vim'           # GitHub Copilot
# Removed rookie_toys.vim plugin
call plug#end()
set statusline=%f:%l:%c\ %m%r%h%w%q%y%{FugitiveStatusline()} laststatus=2 shortmess=flnxtocTOCI
set redrawtime=10000
# Removed GC, GG, GGL commands
nnoremap <C-y> :NERDTreeToggle<CR>
nnoremap <F10> :copen <bar> AsyncRun cargo
autocmd User LspSetup call LspOptionsSet({
\ autoHighlightDiags: v:true,
\ diagVirtualTextAlign: 'after',
\ showDiagWithVirtualText: v:true
\ })
autocmd User LspSetup call LspAddServer([
\ {name: 'javascript', filetype: ['javascript', 'typescript', 'javascriptreact', 'typescriptreact'], path: 'typescript-language-server', args: ['--stdio'], syncInit: v:true},
\ {name: 'go', filetype: ['go'], path: 'gopls', args: [], syncInit: v:true},
\ {name: 'pylsp', filetype: ['python'], path: 'pylsp', args: [], syncInit: v:true}
\ ])
nnoremap <leader>rn :LspRename<CR>
nnoremap <silent> <S-M-f> :LspFormat<CR>
nnoremap <silent> <leader>hh :LspSwitchSourceHeader<CR>
nnoremap <silent> [d :LspDiagPrev<CR>
nnoremap <silent> ]d :LspDiagNext<CR>
nnoremap <silent> gS :LspSymbolSearch<CR>
nnoremap <silent> gd :LspGotoDefinition<CR>
nnoremap <silent> gh :LspHover<CR>
nnoremap <silent> gi :LspGotoImpl<CR>
nnoremap <silent> gr :LspShowReferences<CR>
nnoremap <silent> gs :LspDocumentSymbol<CR>
nnoremap <silent> gy :LspGotoTypeDef<CR>
# Show diagnostics in location list
nnoremap <silent> <leader>dl :LspDiagShow<CR>
# Show diagnostics in a popup window
nnoremap <silent> <leader>ds :LspDiagCurrent<CR>
# Navigate to first diagnostic
nnoremap <silent> <leader>df :LspDiagFirst<CR>
# Copilot keybindings
imap <silent><script><expr> <C-a> copilot#Accept("\<CR>")
imap <C-\> <Plug>(copilot-dismiss)
imap <M-\> <Plug>(copilot-suggest)
imap <M-]> <Plug>(copilot-next)
imap <M-[> <Plug>(copilot-previous)
autocmd BufWritePost *.py !python3 %
#### Easy No plugin ESlint integration (need to find out how to navigate errors)
autocmd FileType javascript,typescript set errorformat=\<text\>:\ line\ %l\\,\ col\ %c\\,\ %m
# Format current buffer with ESlint
nnoremap <silent> <leader>lf :%!eslint_d --stdin --fix-to-stdout<cr> 
nnoremap <silent> <leader>ll :cexpr system('eslint_d --stdin --format compact', bufnr())<cr>:silent cclose<cr>:cc1<cr>
command! Cnext try | cnext | catch | cfirst | catch | endtry
nnoremap <silent> <leader>le :Cnext<cr>
#### End of ESlint integration
