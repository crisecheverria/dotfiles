; Courtesy of nvim-treesitter-textobject
; https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/a0e182ae21fda68c59d1f36c9ed45600aef50311/queries/go/textobjects.scm

; @function.inner
(function_declaration
  body: (block .
    "{" _+ @function.inner "}"))
(func_literal
  body: (block .
    "{" _+ @function.inner "}"))
(method_declaration
  body: (block .
    "{" _+ @function.inner "}"))

; @function.outer
(function_declaration) @function.outer
(func_literal (_)?) @function.outer
(method_declaration body: (block)?) @function.outer

; @class.{inner,outer}
(type_declaration
  (type_spec
    (type_identifier)
    (struct_type
      (field_declaration_list
        (_)?) @class.inner))) @class.outer

(type_declaration
  (type_spec
    (type_identifier)
    (interface_type) @class.inner)) @class.outer

(composite_literal
  (type_identifier)?
  (struct_type
    (_))?
  (literal_value
    (_)) @class.inner) @class.outer

; @blocks
(_
  "{" _+ @block.inner "}") @block.outer
