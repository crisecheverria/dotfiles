local M = {}

M.ns = vim.api.nvim_create_namespace("svenska")

function M.setup()
  local hl = vim.api.nvim_set_hl
  hl(0, "SvenskaTitle", { fg = "#4FC1FF", bold = true })
  hl(0, "SvenskaSubtitle", { fg = "#ABB2BF", italic = true })
  hl(0, "SvenskaSwedish", { fg = "#E5C07B", bold = true })
  hl(0, "SvenskaEnglish", { fg = "#98C379" })
  hl(0, "SvenskaPrompt", { fg = "#C678DD", bold = true })
  hl(0, "SvenskaCorrect", { fg = "#98C379", bold = true })
  hl(0, "SvenskaWrong", { fg = "#E06C75", bold = true })
  hl(0, "SvenskaProgress", { fg = "#61AFEF" })
  hl(0, "SvenskaHint", { fg = "#5C6370", italic = true })
  hl(0, "SvenskaMenuKey", { fg = "#E5C07B", bold = true })
  hl(0, "SvenskaMenuText", { fg = "#ABB2BF" })
  hl(0, "SvenskaScore", { fg = "#D19A66", bold = true })
  hl(0, "SvenskaSeparator", { fg = "#3E4452" })
  hl(0, "SvenskaFlag", { fg = "#006AA7", bold = true })
  hl(0, "SvenskaFlagYellow", { fg = "#FECC00", bold = true })
end

function M.add_hl(buf, line, col_start, col_end, group)
  vim.api.nvim_buf_add_highlight(buf, M.ns, group, line, col_start, col_end)
end

function M.clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
end

return M
