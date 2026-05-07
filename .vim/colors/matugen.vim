" matugen.vim — generated from ~/.config/matugen/templates/matugen.vim
" Do not edit; re-run matugen / matugen-pick to regenerate.

hi clear
if exists('syntax_on') | syntax reset | endif
set background=dark
let g:colors_name = 'matugen'

" --- UI ---
hi Normal        guifg=#e9e0e7 guibg=#161217
hi NormalFloat   guifg=#e9e0e7 guibg=#231e23
hi FloatBorder   guifg=#978e97    guibg=#231e23
hi EndOfBuffer   guifg=#161217    guibg=#161217
hi LineNr        guifg=#978e97    guibg=#161217
hi CursorLine                                           guibg=#1f1a1f gui=NONE cterm=NONE
hi CursorLineNr  guifg=#e5b7f2    guibg=#1f1a1f gui=bold cterm=bold
hi SignColumn                                           guibg=#161217
hi VertSplit     guifg=#4c444d guibg=#161217
hi ColorColumn                                          guibg=#231e23
hi Folded        guifg=#cec3cd guibg=#1f1a1f
hi NonText       guifg=#4c444d
hi Whitespace    guifg=#4c444d

" --- Statusline / tabline ---
hi StatusLine    guifg=#e9e0e7         guibg=#2d282e
hi StatusLineNC  guifg=#cec3cd guibg=#231e23
hi TabLine       guifg=#cec3cd guibg=#231e23
hi TabLineFill                                                  guibg=#110d12
hi TabLineSel    guifg=#452253         guibg=#e5b7f2 gui=bold cterm=bold

" --- Search / selection / messages ---
hi Search        guifg=#ffdad8 guibg=#663b39
hi IncSearch     guifg=#452253            guibg=#e5b7f2
hi CurSearch     guifg=#452253            guibg=#e5b7f2 gui=bold cterm=bold
hi Visual                                                          guibg=#383339
hi MatchParen    guifg=#f5b7b4              guibg=#2d282e gui=bold cterm=bold
hi ErrorMsg      guifg=#ffb4ab     gui=bold cterm=bold
hi WarningMsg    guifg=#f5b7b4  gui=bold cterm=bold
hi ModeMsg       guifg=#e5b7f2   gui=bold cterm=bold
hi Title         guifg=#e5b7f2   gui=bold cterm=bold
hi Directory     guifg=#e5b7f2

" --- Popup (fzf, completion) ---
hi Pmenu         guifg=#e9e0e7            guibg=#231e23
hi PmenuSel      guifg=#f8d8ff  guibg=#5d386b gui=bold cterm=bold
hi PmenuSbar                                                       guibg=#2d282e
hi PmenuThumb                                                      guibg=#e5b7f2

" --- Diff ---
hi DiffAdd                                                         guibg=#514254
hi DiffChange                                                      guibg=#663b39
hi DiffDelete    guifg=#ffdad6    guibg=#93000a
hi DiffText      guifg=#f8d8ff  guibg=#5d386b gui=bold cterm=bold

" --- Syntax ---
hi Comment       guifg=#cec3cd gui=italic cterm=italic
hi Constant      guifg=#f5b7b4
hi String        guifg=#f5b7b4
hi Number        guifg=#f5b7b4
hi Boolean       guifg=#f5b7b4
hi Identifier    guifg=#e9e0e7
hi Function      guifg=#e5b7f2
hi Statement     guifg=#e5b7f2   gui=bold cterm=bold
hi Conditional   guifg=#e5b7f2   gui=bold cterm=bold
hi Repeat        guifg=#e5b7f2   gui=bold cterm=bold
hi Keyword       guifg=#e5b7f2   gui=bold cterm=bold
hi Operator      guifg=#d4c0d7
hi PreProc       guifg=#d4c0d7
hi Include       guifg=#d4c0d7
hi Type          guifg=#f5b7b4
hi StorageClass  guifg=#f5b7b4
hi Structure     guifg=#f5b7b4
hi Special       guifg=#f5b7b4
hi Delimiter     guifg=#cec3cd
hi Underlined    guifg=#e5b7f2   gui=underline cterm=underline
hi Todo          guifg=#ffdad8 guibg=#663b39 gui=bold cterm=bold
hi Error         guifg=#690005              guibg=#ffb4ab

" --- ALE ---
hi ALEErrorSign     guifg=#ffb4ab     guibg=#161217
hi ALEWarningSign   guifg=#f5b7b4  guibg=#161217
hi ALEInfoSign      guifg=#d4c0d7 guibg=#161217
hi ALEError         guifg=#ffb4ab     gui=underline cterm=underline
hi ALEWarning       guifg=#f5b7b4  gui=underline cterm=underline

" --- gitgutter ---
hi GitGutterAdd     guifg=#f5b7b4  guibg=#161217
hi GitGutterChange  guifg=#d4c0d7 guibg=#161217
hi GitGutterDelete  guifg=#ffb4ab     guibg=#161217
