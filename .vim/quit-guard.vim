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
