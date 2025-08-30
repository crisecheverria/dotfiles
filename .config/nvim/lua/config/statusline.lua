-- internal state for toggles
local state = {
  show_path = true,
  show_branch = true,
}

-- config for placeholders + highlighting
local config = {
  icons = {
    path = "",
    branch_hidden = "",
  },
  placeholder_hl = "StatusLineDim", -- a dim highlight group we define below
}

-- helper to wrap text in a statusline highlight group
local function hl(group, text)
  return string.format("%%#%s#%s%%*", group, text)
end

-- set (or link) the dim highlight once
vim.api.nvim_set_hl(0, config.placeholder_hl, {}) -- create if missing
-- Link to Comment to keep it dim; adjust as you like
vim.api.nvim_set_hl(0, config.placeholder_hl, { link = "Comment" })

local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")

  if fpath == "" or fpath == "." then
    return ""
  end

  if state.show_path then
    return string.format("%%<%s/", fpath)
  end

  return hl(config.placeholder_hl, config.icons.path .. "/")
end

local function git()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == "" then
    return ""
  end

  local head    = git_info.head
  local added   = git_info.added and (" +" .. git_info.added) or ""
  local changed = git_info.changed and (" ~" .. git_info.changed) or ""
  local removed = git_info.removed and (" -" .. git_info.removed) or ""
  if git_info.added == 0 then added = "" end
  if git_info.changed == 0 then changed = "" end
  if git_info.removed == 0 then removed = "" end

  if not state.show_branch then
    head = hl(config.placeholder_hl, config.icons.branch_hidden)
  end

  return table.concat({
    "[ ",
    head,
    added, changed, removed,
    "]",
  })
end

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warnings = counts[vim.diagnostic.severity.WARN] or 0
  local info = counts[vim.diagnostic.severity.INFO] or 0
  local hints = counts[vim.diagnostic.severity.HINT] or 0

  if errors == 0 and warnings == 0 and info == 0 and hints == 0 then
    return ""
  end

  local parts = {}
  if errors > 0 then table.insert(parts, "E" .. errors) end
  if warnings > 0 then table.insert(parts, "W" .. warnings) end
  if info > 0 then table.insert(parts, "I" .. info) end
  if hints > 0 then table.insert(parts, "H" .. hints) end

  return "[" .. table.concat(parts, " ") .. "]"
end

Statusline = {}

function Statusline.active()
  return table.concat {
    "[", filepath(), "%t] ",
    git(),
    " ",
    diagnostics(),
    "%=",
    "%y [%P %l:%c]"
  }
end

function Statusline.inactive()
  return " %t"
end

function Statusline.toggle_path()
  state.show_path = not state.show_path
  vim.cmd("redrawstatus")
end

function Statusline.toggle_branch()
  state.show_branch = not state.show_branch
  vim.cmd("redrawstatus")
end

vim.keymap.set("n", "<leader>sp", function() Statusline.toggle_path() end, { desc = "Toggle statusline path" })
vim.keymap.set("n", "<leader>sb", function() Statusline.toggle_branch() end, { desc = "Toggle statusline git branch" })

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = group,
  desc = "Activate statusline on focus",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.Statusline.active()"
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = group,
  desc = "Deactivate statusline when unfocused",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
  end,
})
