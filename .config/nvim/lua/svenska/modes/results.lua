local state = require("svenska.state")
local ui = require("svenska.ui")
local hl = require("svenska.highlight")

local M = {}

function M.show()
  state.mode = "results"
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = ui.create_buf()
    ui.show_buf(buf)
  end

  local width = vim.o.columns
  local pct = state.total > 0 and math.floor((state.correct / state.total) * 100) or 0

  local mode_names = {
    vocabulary = "Vocabulary",
    typing = "Typing Practice",
    translate = "Sentence Translation",
  }
  local mode_name = mode_names[state.game_mode] or "Practice"

  local lines = {
    "",
    ui.center_pad("── Round Complete! ──", width),
    "",
    ui.center_pad(mode_name, width),
    "",
    ui.center_pad(string.format("Score: %d / %d  (%d%%)", state.correct, state.total, pct), width),
    "",
    ui.separator(width),
    "",
  }

  -- Show individual answers
  for i, ans in ipairs(state.answers) do
    local mark = ans.correct and " ✓ " or " ✗ "
    local line = string.format("  %s  %s = %s", mark, ans.sv, ans.en)
    if not ans.correct then
      line = line .. "  (you: " .. ans.given .. ")"
    end
    table.insert(lines, line)
  end

  table.insert(lines, "")
  table.insert(lines, ui.separator(width))
  table.insert(lines, "")

  -- Lifetime stats
  local stats = state.load_stats()
  local lifetime_pct = stats.total_played > 0
    and math.floor((stats.total_correct / stats.total_played) * 100)
    or 0
  table.insert(lines, ui.center_pad(string.format("Lifetime: %d correct / %d total (%d%%) across %d sessions",
    stats.total_correct, stats.total_played, lifetime_pct, stats.sessions), width))

  table.insert(lines, "")
  table.insert(lines, ui.center_pad("Press  m  to return to menu   |   Press  r  to replay   |   Press  q  to quit", width))

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, "SvenskaSubtitle")
  hl.add_hl(buf, 5, 0, -1, "SvenskaScore")

  -- Highlight individual answers
  local answer_start = 9
  for i, ans in ipairs(state.answers) do
    local line_idx = answer_start + i - 1
    if line_idx < #lines then
      hl.add_hl(buf, line_idx, 0, -1, ans.correct and "SvenskaCorrect" or "SvenskaWrong")
    end
  end

  -- Lifetime stats highlight
  local lifetime_line = #lines - 3
  if lifetime_line >= 0 then
    hl.add_hl(buf, lifetime_line, 0, -1, "SvenskaProgress")
  end

  -- Keymaps for results screen
  local opts = { buffer = buf, nowait = true }
  vim.keymap.set("n", "m", function()
    require("svenska").show_menu()
  end, opts)
  vim.keymap.set("n", "r", function()
    require("svenska").replay()
  end, opts)
  vim.keymap.set("n", "q", function()
    require("svenska").quit()
  end, opts)
end

return M
