" =============================================================================================
" Navigation Remapping (Splits, Windows, and Buffers)
" =============================================================================================

" Splits
" Equalize splits when the terminal resizes
autocmd VimResized * wincmd =

" Resize splits quickly (Ctrl+w + < or >) and (Alt+Up or Down)
nnoremap <C-w>< :vertical resize -5<CR>
nnoremap <C-w>> :vertical resize +5<CR>
nnoremap <A-Up>    :resize +3<CR>
nnoremap <A-Down>  :resize -3<CR>

" Windows
" Easy Movement Between Windows (Leader + a, Leader + d | OR | C-Right, C-Left)
nnoremap <leader>a <C-w>h
nnoremap <leader>d <C-w>l
" Normal mode — smart window hop with fallback to default key behavior
nnoremap <expr> <C-Left>  winnr('$') > 1 ? '<C-w>h' :'h'
nnoremap <expr> <C-Right> winnr('$') > 1 ? '<C-w>l' : 'l'


" Easy Movement Between Buffers (Leader + b, Leader + n | OR | C-S-Left, C-S-Right)
nnoremap <leader>b  :bprevious<CR>
nnoremap <leader>n :bnext<CR>
" Normal mode — smart buffer hop with fallback to default key behavior
nnoremap <expr> <C-S-Left>  winnr('$') > 1 ? ':bprevious<CR>' : 'h'
nnoremap <expr> <C-S-Right>  winnr('$') > 1 ? ':bnext<CR>' : 'l'
