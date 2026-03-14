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
