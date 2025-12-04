" =============================================================================================
" Basic Settings
" =============================================================================================
set nocompatible              " Use Vim defaults (not Vi)
filetype plugin indent on     " Enable filetype detection + plugins
syntax on                     " Enable syntax highlighting
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

" =============================================================================================
" Leader Key
" =============================================================================================
let mapleader="\<Space>"

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

"Color Scheme
Plug 'ap/vim-css-color'
Plug 'c9rgreen/vim-colors-modus'
Plug 'ghifarit53/tokyonight-vim'

call plug#end()

" =============================================================================================
" Settings
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
set grepprg=rg\ --vimgrep
" Note: Custom :Rg command commented out to use FZF's interactive :Rg instead
" command! -nargs=* Rg silent grep! <args> | copen

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

" =============================================================================================
" General Keybindings
" =============================================================================================

" File Explorer (netrw)
nnoremap <leader>e :Ex<CR>
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

" =============================================================================================
" Navigation Remapping (Splits, Windows, and Buffers)
" =============================================================================================

" Splits
" Equalize splits when the terminal resizes
autocmd VimResized * wincmd =

" Resize splits quickly (Alt + arrows)
nnoremap <A-Left>  :vertical resize -5<CR>
nnoremap <A-Right> :vertical resize +5<CR>
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
nnoremap <expr> <C-S-Left>  :winnr('$') > 1 ? ':bprevious<CR>' : 'h'
nnoremap <expr> <C-S-Right>  :winnr('$') > 1 ? ':bnext<CR>' : 'l'

" =============================================================================================
" COC Setup
" =============================================================================================

" COC
" Returns true if cursor is at start of line or preceded by whitespace
function! CheckBackspace() abort
  let col = col('.') - 1
  return col <= 0 || getline('.')[col - 1] =~# '\s'
endfunction

" Remap TAB to work with COC
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm(): "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <c-@> coc#refresh()

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Show diagnostics
nmap <silent> <leader>x :CocDiagnostics<CR>

" Show documentation
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Run tests for current file
nnoremap <leader>t :call RunCurrentTest()<CR>

function! RunCurrentTest()
  let l:file = expand('%:p')
  let l:root = FindGitRoot()
  let l:rel = l:root !=# '' ? substitute(l:file, l:root . '/', '', '') : l:file
  " Remove packages/ prefix for monorepo structure
  let l:rel = substitute(l:rel, '^packages/', '', '')

  if l:file =~# '\.test\.\(ts\|tsx\|js\|jsx\)$' || l:file =~# '__tests__'
    execute '!npm run test -- ' . shellescape(l:rel)
  elseif l:file =~# '\.spec\.\(ts\|tsx\|js\|jsx\)$'
    execute '!npm run test -- ' . shellescape(l:rel)
  elseif l:file =~# '_test\.py$' || l:file =~# 'test_.*\.py$'
    execute '!pytest ' . shellescape(l:file)
  elseif l:file =~# '_test\.go$'
    execute '!go test ' . shellescape(expand('%:h'))
  else
    echo 'Not a test file'
  endif
endfunction

function! FindGitRoot()
  let l:path = expand('%:p:h')
  while l:path !=# '/' && l:path !=# ''
    if isdirectory(l:path . '/.git')
      return l:path
    endif
    let l:path = fnamemodify(l:path, ':h')
  endwhile
  return ''
endfunction

" =============================================================================================
" TaskPaper Per File ToDo (new, remove if you don't care about TODO lists)
" =============================================================================================
let g:tp_project_file = 'tasks.taskpaper'

" find nearest tasks.taskpaper by walking upward
function! s:TP_ProjectFile() abort
  let d = expand('%:p:h')
  while 1
    if filereadable(d.'/'.g:tp_project_file) | return d.'/'.g:tp_project_file | endif
    let p = fnamemodify(d, ':h')
    if p ==# d | return '' | endif
    let d = p
  endwhile
endfunction

" lines in project file that reference THIS buffer (abs path only)
function! s:TP_LinesForBuf() abort
  let pf = s:TP_ProjectFile()
  if pf ==# '' | return [] | endif
  let abs  = expand('%:p')
  let real = resolve(abs)          " follows symlinks; often different in WSL
  let p1 = '\V@file(' . escape(abs,'\')  . ')'
  let p2 = '\V@file(' . escape(real,'\') . ')'
  return filter(readfile(pf), {_,v -> v =~? p1 || v =~? p2})
endfunction

" popup state + filter (q / Esc closes)
let s:tp_popup_id = -1

function! s:TP_PopupVisible() abort
  return s:tp_popup_id > 0 && !empty(popup_getpos(s:tp_popup_id))
endfunction

" close on q / Esc
function! s:TP_PopupFilter(id, key) abort
  if a:key ==# 'q' || a:key ==# "\<Esc>"
    call popup_close(a:id)
    return 1
  endif
  return 0
endfunction

" Strip @file(...) / @file=... / @file: ... / @file <path> from ONE line
function! s:TP_StripOneLine(idx, val) abort
  let s = a:val
  " @file(...)
  let s = substitute(s, '\s*@file(\([^)]\+\))', '', 'gi')
  " @file=path   or   @file: path
  let s = substitute(s, '\s*@file\s*[:=]\s*\S\+', '', 'gi')
  " @file path
  let s = substitute(s, '\s*@file\s\+\S\+', '', 'gi')
  " trim trailing spaces
  let s = substitute(s, '\s\+$', '', '')
  return s
endfunction

" Strip file tags from a list of lines (map passes idx,val)
function! s:TP_StripFileTags(lines) abort
  return map(copy(a:lines), function('<SID>TP_StripOneLine'))
endfunction

" Show once per buffer on open
function! s:TP_ShowOnce() abort
  if get(b:, 'tp_popup_seen', 0) | return | endif
  let l:lines = <SID>TP_LinesForBuf()
  if empty(l:lines) || !has('popupwin') | return | endif

  let l:disp = <SID>TP_StripFileTags(l:lines)

  " If already visible, just update its text
  if s:TP_PopupVisible()
    call popup_settext(s:tp_popup_id, l:disp)
    let b:tp_popup_seen = 1
    return
  endif

  " Create a new popup with the lines list directly
  let l:w = min([80, &columns - 4])
  let l:h = min([10, &lines   - 4])
  let l:opts = {
        \ 'line': (&lines - l:h)/2, 'col': (&columns - l:w)/2,
        \ 'minwidth': l:w, 'minheight': l:h, 'maxwidth': l:w, 'maxheight': l:h,
        \ 'border': [1,1,1,1], 'title': 'Tasks for '.expand('%:t'),
        \ 'mapping': 1, 'zindex': 300 }
  let s:tp_popup_id = popup_create(l:disp, l:opts)
  call popup_setoptions(s:tp_popup_id, { 'filter': function('<SID>TP_PopupFilter') })

  let b:tp_popup_seen = 1
endfunction

" Toggle: close if visible; else force show (ignores 'seen' once)
function! s:TP_Toggle() abort
  if s:TP_PopupVisible()
    call popup_close(s:tp_popup_id) | let s:tp_popup_id = -1
  else
    let save = get(b:, 'tp_popup_seen', 0)
    let b:tp_popup_seen = 0 | call <SID>TP_ShowOnce() | let b:tp_popup_seen = save
  endif
endfunction

augroup TP_Popup_Min
  autocmd!
  autocmd BufReadPost,BufNewFile * let b:tp_popup_seen = 0 | call <SID>TP_ShowOnce()
augroup END

nnoremap <leader>tt :call <SID>TP_Toggle()<CR>

" =============================================================================================
" TaskPaper Add Task Commands (new, remove if you don't care about TODO lists)
" =============================================================================================

" Helper: nearest project file (reuse if you already defined it)
if !exists('*<SID>TP_ProjectFile')
  function! s:TP_ProjectFile() abort
    let d = expand('%:p:h')
    while 1
      if filereadable(d.'/'.g:tp_project_file) | return d.'/'.g:tp_project_file | endif
      let p = fnamemodify(d, ':h')
      if p ==# d | return d.'/'.g:tp_project_file | endif
      let d = p
    endwhile
  endfunction
endif

" Append lines to a file, inserting a blank line if the file is nonempty
function! s:TP_AppendLines(filepath, lines) abort
  let f = a:filepath
  if filereadable(f)
    let cur = readfile(f)
    if !empty(cur) && cur[-1] !~# '\n\?$'
      " writefile always adds NL; just ensure spacing visually with a blank line
      call writefile([''], f, 'a')
    endif
  endif
  call writefile(a:lines, f, 'a')
endfunction

" Core adder
function! s:TP_AddTask(task_text, mark_done) abort
  let txt = trim(a:task_text)
  if empty(txt)
    echoerr 'TPAdd: task text is empty'
    return
  endif
  let pf = <SID>TP_ProjectFile()
  " ensure the parent dir exists (it should), create file if missing by appending
  let abs = resolve(expand('%:p'))
  let iso = strftime('%Y-%m-%d')
  let line = '- ' . txt . ' @file(' . abs . ')'
  if a:mark_done
    let line .= ' @done(' . iso . ')'
  endif
  call s:TP_AppendLines(pf, [line])
  " Refresh the popup for this buffer once
  if exists('*<SID>TP_ShowOnce')
    let b:tp_popup_seen = 0
    call <SID>TP_ShowOnce()
  endif
  echo 'Added task → ' . pf
endfunction

" Commands
command! -nargs=+ COMPLETE  call <SID>TP_AddTask(<q-args>, 1)
"command! -nargs=0 TODO call <SID>TP_AddTask(input('Task: '), 0)
" Replace your TPAddPrompt with a cancel-friendly version
command! -nargs=0 TODO call <SID>TP_AddPrompt()

function! s:TP_AddPrompt() abort
  let txt = ''
  try
    let txt = input('Task: ')
  catch /^Vim:Interrupt$/
    return
  endtry
  if empty(trim(txt))           " Esc+Enter or just Enter → cancel
    return
  endif
  call <SID>TP_AddTask(txt, 0)  " reuse your core adder
endfunction

nnoremap <silent> <leader>td :TODO<CR>
nnoremap <silent> <leader>tdc :COMPLETE<CR>

" =============================================================================================
" Auto Open Side Bars (NERDTree and TagBar)
" =============================================================================================

" ---------- Open NERDTree/Tagbar only if NOT already open (per tab) ----------
function! s:is_real_file() abort
  return &buftype ==# '' && bufname('%') !=# ''
endfunction

function! s:tab_has_ft(ft) abort
  for w in range(1, winnr('$'))
    if getbufvar(winbufnr(w), '&filetype') ==# a:ft
      return 1
    endif
  endfor
  return 0
endfunction

function! s:ensure_sidebars(opt_ft_scope) abort
  if exists('g:smart_quitting') | return | endif

  if !<SID>is_real_file() | return | endif
  if a:opt_ft_scope !=# '' && &filetype !=# a:opt_ft_scope | return | endif

  " NERDTree once per tab
  " if exists(':NERDTree') == 2 && !<SID>tab_has_ft('nerdtree')
  "   silent! execute 'vertical NERDTree'
  "   noautocmd wincmd p
  " endif

  " Tagbar once per tab (no-op if unsupported)
  if exists(':TagbarOpen') == 2 && !<SID>tab_has_ft('tagbar')
    silent! execute 'TagbarOpen'
    noautocmd wincmd p
  endif
endfunction

augroup SidebarsAuto_Idempotent
  autocmd!
  let g:sidebar_ft_scope = 'python'   " '' for all filetypes; 'python' to restrict
  autocmd VimEnter,TabEnter,BufWinEnter * call <SID>ensure_sidebars(g:sidebar_ft_scope)
augroup END

" =============================================================================================
" Smart Save for Multiple Files in Buffers (Smart :q and smart :wq)
" =============================================================================================

" ---- Smart :bd: switch to another buffer first, then delete the old one ----
" function! s:is_real_file_buf(b) abort
"   return a:b > 0
"         \ && buflisted(a:b)
"         \ && bufname(a:b) !=# ''
"         \ && getbufvar(a:b,'&buftype') ==# ''
"         \ && index(['nerdtree','tagbar','help','qf','terminal'], getbufvar(a:b,'&filetype')) < 0
" endfunction

" function! s:SmartBdeleteSwitch(bang) abort
"   let l:cur = bufnr('%')
"   let l:tgt = -1
"   if bufnr('#') > 0 && bufnr('#') != l:cur && <SID>is_real_file_buf(bufnr('#'))
"     let l:tgt = bufnr('#')
"   else
"     for l:info in getbufinfo({'buflisted':1})
"       if l:info.bufnr != l:cur && <SID>is_real_file_buf(l:info.bufnr)
"         let l:tgt = l:info.bufnr | break
"       endif
"     endfor
"   endif
"   if l:tgt == -1 | enew | let l:tgt = bufnr('%') | else | execute 'buffer' l:tgt | endif
"   execute 'bdelete' . a:bang . ' ' . l:cur
" endfunction

" command! -bang BDSwitch call <SID>SmartBdeleteSwitch(<q-bang>)
" cnoreabbrev <expr> bd (getcmdtype()==':' && getcmdline() =~# '^\s*bd\%(\s*!\)\?\s*$')
"       \ ? (getcmdline() =~# '!\s*$' ? 'BDSwitch!' : 'BDSwitch')
"       \ : 'bd'

" function! s:real_file_buf_count_all() abort
"   let l:n = 0
"   for l:info in getbufinfo({'buflisted': 1})
"     if <SID>is_real_file_buf(l:info.bufnr)
"       let l:n += 1
"     endif
"   endfor
"   return l:n
" endfunction

" " --- :q that calls :bd when more than one real file buffer exists, else quit-all ---
" function! s:SmartConditionalQuit(bang) abort
"   if <SID>real_file_buf_count_all() > 1
"     " More than one real buffer → switch-first-then-delete
"     execute 'BDSwitch' . a:bang
"   else
"     " One or zero → leave cleanly (mute autocommands to avoid E1312 noise)
"     execute 'noautocmd qa' . a:bang
"   endif
" endfunction

" command! -bang SmartCQuit call <SID>SmartConditionalQuit(<q-bang>)

" " --- :wq that calls :w and then BDSwitch (smart buffer close) when more than one real file buffer exists, else write-quit-all ---
" function! s:SmartConditionalWriteQuit(bang) abort
"   if <SID>real_file_buf_count_all() > 1
"     " Write current buffer, then switch+delete current buffer
"     execute 'write' . a:bang
"     execute 'BDSwitch' . a:bang
"   else
"     " One or zero real buffers → write-all & quit-all (muted to avoid noisy autocmds)
"     execute 'noautocmd wqa' . a:bang
"   endif
" endfunction

" command! -bang SmartCWQ call <SID>SmartConditionalWriteQuit(<q-bang>)

" " Only rewrite an exact :q / :q! to our smart quitter (preserve !)
" cnoreabbrev <expr> q
"       \ (getcmdtype() == ':' && getcmdline() =~# '^\s*q\%(\s*!\)\?\s*$')
"       \ ? (getcmdline() =~# '!\s*$' ? 'SmartCQuit!' : 'SmartCQuit')
"       \ : 'q'

" " Only rewrite exact :wq / :wq! (preserve !)
" cnoreabbrev <expr> wq
"       \ (getcmdtype()==':' && getcmdline() =~# '^\s*wq\%(\s*!\)\?\s*$')
"       \ ? (getcmdline() =~# '!\s*$' ? 'SmartCWQ!' : 'SmartCWQ')
"       \ : 'wq'

" =============================================================================================
" Persistence Logic (View, Session, Undo stay the same on restart)
" =============================================================================================

" Persistent View block with guarded function
augroup AutoView
  autocmd!
  autocmd BufWinLeave * call <SID>AutoViewSave()
  autocmd BufWinEnter * call <SID>AutoViewLoad()
augroup END

function! s:AutoViewSave() abort
  if exists('g:smart_quitting') | return | endif
  if &buftype ==# '' | silent! mkview | endif
endfunction

function! s:AutoViewLoad() abort
  if exists('g:smart_quitting') | return | endif
  if &buftype ==# '' | silent! loadview | endif
endfunction

" Auto-save session on exit *if* we started with no files
augroup AutoSession
  autocmd!
  autocmd VimLeavePre * if argc() == 0 | silent! mksession! ~/.vim/session.vim | endif
augroup END

" Auto-load session on start *only* if no files were given
if argc() == 0 && filereadable(expand('~/.vim/session.vim'))
  silent! source ~/.vim/session.vim
endif

" Persistent undo
set undofile
if !isdirectory($HOME.'/.vim/undo') | call mkdir($HOME.'/.vim/undo', 'p') | endif
set undodir=~/.vim/undo

" Ensure autopairs initializes whenever a real buffer becomes active
augroup AutoPairsInitShim
  autocmd!
  autocmd BufEnter,FileType,InsertEnter * if exists('*AutoPairsTryInit') | call AutoPairsTryInit() | endif
augroup END

" =============================================================================================
" Quit Guard to Ignore Layout Events (Allows smart :q and smart :wq to function properly)
" =============================================================================================

" Highlight trailing spaces; strip on save (non-intrusive)
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Strip on save
autocmd BufWritePre * %s/\s\+$//e
" Guard around quits: set a flag and temporarily ignore layout events
augroup SmartQuitGuard
  autocmd!
  autocmd QuitPre * call <SID>_sqg_on()
augroup END

" Quit Guard for Smart Quit
function! s:_sqg_on() abort
  let g:smart_quitting = 1
  " stash current eventignore and mute the noisy ones
  let t:_sqg_ei = &eventignore
  let &eventignore = (empty(&eventignore) ? '' : &eventignore.',')
        \ . 'WinEnter,BufEnter,BufWinEnter,WinLeave,BufLeave,TabEnter,TabLeave'
  " auto-restore after a short delay (if Vim didn't exit)
  call timer_start(250, {-> execute('let &eventignore=get(t:, "_sqg_ei", "") | silent! unlet t:_sqg_ei | silent! unlet g:smart_quitting')})
endfunction

" =============================================================================================
" .idevimrc setup for IdeaVim (if detected)
" =============================================================================================
if has('ide')
  " mappings and options that exist only in IdeaVim
  map <leader>f <Action>(GotoFile)
  map <leader>g <Action>(FindInPath)
  map <leader>b <Action>(Switcher)

  if &ide =~? 'intellij idea'
    if &ide =~? 'community'
      " some mappings and options for IntelliJ IDEA Community Edition
    elseif &ide =~? 'ultimate'
      " some mappings and options for IntelliJ IDEA Ultimate Edition
    endif
  elseif &ide =~? 'pycharm'
    " PyCharm specific mappings and options
  endif
endif
