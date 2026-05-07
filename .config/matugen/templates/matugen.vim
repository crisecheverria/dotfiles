" matugen.vim — generated from ~/.config/matugen/templates/matugen.vim
" Do not edit; re-run matugen / matugen-pick to regenerate.

hi clear
if exists('syntax_on') | syntax reset | endif
set background=dark
let g:colors_name = 'matugen'

" --- UI ---
hi Normal        guifg={{colors.on_surface.default.hex}} guibg={{colors.surface.default.hex}}
hi NormalFloat   guifg={{colors.on_surface.default.hex}} guibg={{colors.surface_container.default.hex}}
hi FloatBorder   guifg={{colors.outline.default.hex}}    guibg={{colors.surface_container.default.hex}}
hi EndOfBuffer   guifg={{colors.surface.default.hex}}    guibg={{colors.surface.default.hex}}
hi LineNr        guifg={{colors.outline.default.hex}}    guibg={{colors.surface.default.hex}}
hi CursorLine                                           guibg={{colors.surface_container_low.default.hex}} gui=NONE cterm=NONE
hi CursorLineNr  guifg={{colors.primary.default.hex}}    guibg={{colors.surface_container_low.default.hex}} gui=bold cterm=bold
hi SignColumn                                           guibg={{colors.surface.default.hex}}
hi VertSplit     guifg={{colors.outline_variant.default.hex}} guibg={{colors.surface.default.hex}}
hi ColorColumn                                          guibg={{colors.surface_container.default.hex}}
hi Folded        guifg={{colors.on_surface_variant.default.hex}} guibg={{colors.surface_container_low.default.hex}}
hi NonText       guifg={{colors.outline_variant.default.hex}}
hi Whitespace    guifg={{colors.outline_variant.default.hex}}

" --- Statusline / tabline ---
hi StatusLine    guifg={{colors.on_surface.default.hex}}         guibg={{colors.surface_container_high.default.hex}}
hi StatusLineNC  guifg={{colors.on_surface_variant.default.hex}} guibg={{colors.surface_container.default.hex}}
hi TabLine       guifg={{colors.on_surface_variant.default.hex}} guibg={{colors.surface_container.default.hex}}
hi TabLineFill                                                  guibg={{colors.surface_container_lowest.default.hex}}
hi TabLineSel    guifg={{colors.on_primary.default.hex}}         guibg={{colors.primary.default.hex}} gui=bold cterm=bold

" --- Search / selection / messages ---
hi Search        guifg={{colors.on_tertiary_container.default.hex}} guibg={{colors.tertiary_container.default.hex}}
hi IncSearch     guifg={{colors.on_primary.default.hex}}            guibg={{colors.primary.default.hex}}
hi CurSearch     guifg={{colors.on_primary.default.hex}}            guibg={{colors.primary.default.hex}} gui=bold cterm=bold
hi Visual                                                          guibg={{colors.surface_container_highest.default.hex}}
hi MatchParen    guifg={{colors.tertiary.default.hex}}              guibg={{colors.surface_container_high.default.hex}} gui=bold cterm=bold
hi ErrorMsg      guifg={{colors.error.default.hex}}     gui=bold cterm=bold
hi WarningMsg    guifg={{colors.tertiary.default.hex}}  gui=bold cterm=bold
hi ModeMsg       guifg={{colors.primary.default.hex}}   gui=bold cterm=bold
hi Title         guifg={{colors.primary.default.hex}}   gui=bold cterm=bold
hi Directory     guifg={{colors.primary.default.hex}}

" --- Popup (fzf, completion) ---
hi Pmenu         guifg={{colors.on_surface.default.hex}}            guibg={{colors.surface_container.default.hex}}
hi PmenuSel      guifg={{colors.on_primary_container.default.hex}}  guibg={{colors.primary_container.default.hex}} gui=bold cterm=bold
hi PmenuSbar                                                       guibg={{colors.surface_container_high.default.hex}}
hi PmenuThumb                                                      guibg={{colors.primary.default.hex}}

" --- Diff ---
hi DiffAdd                                                         guibg={{colors.secondary_container.default.hex}}
hi DiffChange                                                      guibg={{colors.tertiary_container.default.hex}}
hi DiffDelete    guifg={{colors.on_error_container.default.hex}}    guibg={{colors.error_container.default.hex}}
hi DiffText      guifg={{colors.on_primary_container.default.hex}}  guibg={{colors.primary_container.default.hex}} gui=bold cterm=bold

" --- Syntax ---
hi Comment       guifg={{colors.on_surface_variant.default.hex}} gui=italic cterm=italic
hi Constant      guifg={{colors.tertiary.default.hex}}
hi String        guifg={{colors.tertiary.default.hex}}
hi Number        guifg={{colors.tertiary.default.hex}}
hi Boolean       guifg={{colors.tertiary.default.hex}}
hi Identifier    guifg={{colors.on_surface.default.hex}}
hi Function      guifg={{colors.primary.default.hex}}
hi Statement     guifg={{colors.primary.default.hex}}   gui=bold cterm=bold
hi Conditional   guifg={{colors.primary.default.hex}}   gui=bold cterm=bold
hi Repeat        guifg={{colors.primary.default.hex}}   gui=bold cterm=bold
hi Keyword       guifg={{colors.primary.default.hex}}   gui=bold cterm=bold
hi Operator      guifg={{colors.secondary.default.hex}}
hi PreProc       guifg={{colors.secondary.default.hex}}
hi Include       guifg={{colors.secondary.default.hex}}
hi Type          guifg={{colors.tertiary.default.hex}}
hi StorageClass  guifg={{colors.tertiary.default.hex}}
hi Structure     guifg={{colors.tertiary.default.hex}}
hi Special       guifg={{colors.tertiary.default.hex}}
hi Delimiter     guifg={{colors.on_surface_variant.default.hex}}
hi Underlined    guifg={{colors.primary.default.hex}}   gui=underline cterm=underline
hi Todo          guifg={{colors.on_tertiary_container.default.hex}} guibg={{colors.tertiary_container.default.hex}} gui=bold cterm=bold
hi Error         guifg={{colors.on_error.default.hex}}              guibg={{colors.error.default.hex}}

" --- ALE ---
hi ALEErrorSign     guifg={{colors.error.default.hex}}     guibg={{colors.surface.default.hex}}
hi ALEWarningSign   guifg={{colors.tertiary.default.hex}}  guibg={{colors.surface.default.hex}}
hi ALEInfoSign      guifg={{colors.secondary.default.hex}} guibg={{colors.surface.default.hex}}
hi ALEError         guifg={{colors.error.default.hex}}     gui=underline cterm=underline
hi ALEWarning       guifg={{colors.tertiary.default.hex}}  gui=underline cterm=underline

" --- gitgutter ---
hi GitGutterAdd     guifg={{colors.tertiary.default.hex}}  guibg={{colors.surface.default.hex}}
hi GitGutterChange  guifg={{colors.secondary.default.hex}} guibg={{colors.surface.default.hex}}
hi GitGutterDelete  guifg={{colors.error.default.hex}}     guibg={{colors.surface.default.hex}}
