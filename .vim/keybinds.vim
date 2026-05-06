" =============================================================================================
" General Keybindings
" =============================================================================================

" Space as : for command mode
nnoremap <Space> :
vnoremap <Space> :

" File Explorer (netrw)
nnoremap <leader>e :Ex<CR>
nnoremap <silent> - :VimExplorer<CR>
" Tagbar
nmap <F8> :TagbarToggle<CR>

" Fast openers (swap to your taste)
" FZF File/Buffer/Grep
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <C-p> :Files<CR>
nnoremap <leader><leader> :Buffers<CR>
" grep word under cursor
nnoremap <leader>/ :Rg <C-r><C-w><CR>

" Clear search highlighting
nnoremap <silent> <Esc> :noh<CR>

" Terminal mode: escape with Ctrl+O (Esc conflicts with Ghostty)
tnoremap <C-o> <C-\><C-n>

" Fugitive Git Grep for word under cursor
nnoremap <leader>sw :Grep <C-r><C-w><CR>

" Git review
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gvdiffsplit<CR>
nnoremap <leader>gl :0Gclog<CR>

" Copilot Keybindings
" Accept suggestion: Tab (default)
" Dismiss suggestion: Ctrl+]
" Next suggestion: Alt+]
" Previous suggestion: Alt+[

" Copy current buffer path to clipboard
nnoremap <leader>cp :let @+ = expand('%:p')<CR>:echo 'Copied: ' . expand('%:p')<CR>

" Diff Navigation
nnoremap <leader>dn ]c
nnoremap <leader>dp [c

" GUI Switcher (SWITCHES TO SUBLIME, SWITCH EXECUTIBLE FOR DIFFERENT GUI EDITOR)
command! GUI write | execute '!subl --wait ' . shellescape(expand('%:p'))

" Ale
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nnoremap <silent> <leader>x :ALEPopulateQuickfix<CR>:copen<CR>

" Easy way to get back to normal mode from home row
inoremap jj <Esc>
inoremap jk <Esc>
