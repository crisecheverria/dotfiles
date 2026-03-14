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
