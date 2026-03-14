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
