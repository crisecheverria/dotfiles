; Courtesy of nvim-treesitter-textobjects
; https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/a0e182ae21fda68c59d1f36c9ed45600aef50311/queries/lua/textobjects.scm

; @function.outer
[ (function_declaration) (function_definition) ] @function.outer

; @function.inner
(function_declaration body: (_) @function.inner)
(function_definition body: (_) @function.inner)

; @blocks
(_
  (block) @block.inner) @block.outer
