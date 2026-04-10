; Courtesy of nvim-treesitter-textobject
; https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/a0e182ae21fda68c59d1f36c9ed45600aef50311/queries/c/textobjects.scm

; @function.outer
(declaration declarator: (function_declarator)) @function.outer
(function_definition body: (compound_statement)) @function.outer

; @function.inner
(function_definition
  body: (compound_statement .
    "{" _+ @function.inner "}"))

; @class.{inner, outer}
(struct_specifier
  body: (_) @class.inner) @class.outer
(enum_specifier
  body: (_) @class.inner) @class.outer

; @blocks
(_
  "{" _+ @block.inner "}") @block.outer

