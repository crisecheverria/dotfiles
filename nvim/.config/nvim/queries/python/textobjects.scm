; Courtesy of nvim-treesitter-textobjects
; https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/a0e182ae21fda68c59d1f36c9ed45600aef50311/queries/python/textobjects.scm

; @function{inner,outer}
(decorated_definition
  (function_definition)) @function.outer

(function_definition
  body: (block)? @function.inner) @function.outer

; @class.{inner,outer}
(decorated_definition
  (class_definition)) @class.outer

(class_definition
  body: (block)? @class.inner) @class.outer

; @blocks
(_
  (block) @block.inner) @block.outer
