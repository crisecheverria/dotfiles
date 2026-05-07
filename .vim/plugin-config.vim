" =============================================================================================
" Plugin Configuration
" =============================================================================================

" Color Scheme
let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1
colorscheme matugen

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
let g:copilot_enabled = v:false
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

" Lint quietly: only on insert-leave and save, not while typing
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0

" No inline highlighting — keep a small gutter sign as the only hint
let g:ale_set_highlights = 0
let g:ale_set_signs = 1
let g:ale_sign_error = '●'
let g:ale_sign_warning = '·'

" Show message in the echo line when cursor is on the error
let g:ale_echo_cursor = 1
let g:ale_cursor_detail = 0
let g:ale_virtualtext_cursor = 0

let g:ale_linters = {
\   'python': ['ruff'],
\   'javascript': ['eslint', 'oxlint'],
\   'typescript': ['eslint', 'oxlint'],
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

" In :AIChat buffers, <CR> in normal mode submits (instead of :AIChat<CR>)
augroup VimAIChatSubmit
  autocmd!
  autocmd FileType aichat nnoremap <buffer> <CR> :AIChat<CR>
augroup END
