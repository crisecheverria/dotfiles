" =============================================================================================
" Plugin Configuration
" =============================================================================================

" Color Scheme
let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1
colorscheme tokyonight

" WSL: use Windows clipboard
if has('wsl')
  let g:clipboard = {
  \ 'name': 'WslClip',
  \ 'copy':  { '+': 'clip.exe',  '*': 'clip.exe' },
  \ 'paste': { '+': 'powershell.exe -NoProfile -Command Get-Clipboard',
  \            '*': 'powershell.exe -NoProfile -Command Get-Clipboard' },
  \ 'cache_enabled': 0,
  \ }
endif
set clipboard=unnamed

" ---- Copilot setup ----
" Copilot will prompt you to authenticate on first use
" Accept suggestions with Tab or Ctrl+]

" ---- Highlight on yank ----
let g:highlightedyank_highlight_duration = 150

" ---- Better Grep ----
" Better grep: ripgrep into quickfix
set grepprg=rg\ --vimgrep\ --smart-case
" Note: Custom :Rg command commented out to use FZF's interactive :Rg instead
command! -nargs=+ Grep silent grep! <args> | copen

" ---- Ale setup ----
let g:ale_fix_on_save = 1
let g:ale_linters = {
\   'python': ['ruff'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\   'sh': ['shellcheck'],
\}
let g:ale_fixers  = {
\   'python': ['isort', 'black'],
\   'javascript': ['prettier', 'biome'],
\   'javascriptreact': ['prettier'],
\   'typescript': ['prettier'],
\   'typescriptreact': ['prettier'],
\   'css': ['prettier'],
\   'scss': ['prettier'],
\   'html': ['prettier'],
\   'json': ['prettier'],
\   'yaml': ['prettier'],
\   'markdown': ['prettier'],
\   'sh': ['shfmt'],
\}

" Make ALE use your venv if activated
let g:ale_python_black_executable = 'black'
let g:ale_python_isort_executable = 'isort'
let g:ale_python_ruff_executable = 'ruff'

" ---- Airline Tabs setup ----
" Enable tabline to show all open buffers like tabs
let g:airline#extensions#tabline#enabled = 1
" Optional: show just filename
let g:airline#extensions#tabline#formatter = 'unique_tail'

" ---- NERDTree settings ----
" let g:NERDTreeWinPos = 'left'
" let g:NERDTreeWinSize = 40
" Side-bar QoL
" let g:NERDTreeQuitOnOpen = 1
let g:tagbar_autoclose   = 0

" ---- Netrw settings ----
let g:netrw_banner = 0

" ---- vim-claude-code setup ----
let g:claude_code_map_toggle = '<C-;>'
let g:claude_code_diff_preview = 1

" ---- vim-ai setup ----
let g:vim_ai_roles_config_file = expand('~/.config/vim-ai/roles.ini')
