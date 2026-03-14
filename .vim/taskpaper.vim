" =============================================================================================
" TaskPaper Per File ToDo
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
" TaskPaper Add Task Commands
" =============================================================================================

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
