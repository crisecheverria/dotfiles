local state = require("svenska.state")
local ui = require("svenska.ui")
local hl = require("svenska.highlight")
local words_data = require("svenska.data.words")
local sentences_data = require("svenska.data.sentences")

local M = {}

-- Swedish flag: blue field with yellow Nordic cross (solid blocks, colored by highlights)
-- Proportions: 5 blue | 2 yellow | 9 blue horizontally, 3|2|3 vertically
local FLAG_LINES = {
  "  ████████████████",
  "  ████████████████",
  "  ████████████████",
  "  ████████████████",
  "  ████████████████",
  "  ████████████████",
  "  ████████████████",
  "  ████████████████",
}
-- 16 block chars per line, each █ = 3 bytes
-- Layout: 5 blue (bytes 2-16) + 2 yellow (bytes 17-22) + 9 blue (bytes 23-49)
-- Cross rows (3,4): all yellow (bytes 2-49)

local function get_flag_highlights(line_idx)
  local segs = {}
  if line_idx == 3 or line_idx == 4 then
    table.insert(segs, { 2, 50, "SvenskaFlagYellow" })
  else
    table.insert(segs, { 2, 17, "SvenskaFlag" })
    table.insert(segs, { 17, 23, "SvenskaFlagYellow" })
    table.insert(segs, { 23, 50, "SvenskaFlag" })
  end
  return segs
end

-- Store last game config for replay
local last_game = nil

function M.setup()
  hl.setup()
  math.randomseed(os.time())
  vim.api.nvim_create_user_command("Svenska", function(opts)
    local arg = opts.args
    if arg == "" then
      M.show_menu()
    elseif arg == "stats" then
      M.show_stats()
    else
      M.show_menu()
    end
  end, {
    nargs = "?",
    complete = function()
      return { "stats" }
    end,
  })
end

function M.show_menu()
  state.mode = "menu"
  ui.close_input()

  local buf = ui.create_buf()
  ui.show_buf(buf)

  local width = vim.o.columns

  local lines = {}
  -- Flag
  for _, line in ipairs(FLAG_LINES) do
    table.insert(lines, ui.center_pad(line, width))
  end
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("S V E N S K A", width))
  table.insert(lines, ui.center_pad("Learn Swedish without leaving Neovim", width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad(ui.separator(40), width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("GAME MODES", width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("[1]  Vocabulary    — Translate words (SV↔EN)", width))
  table.insert(lines, ui.center_pad("[2]  Typing        — Type Swedish words & sentences", width))
  table.insert(lines, ui.center_pad("[3]  Translate     — Translate full sentences (EN→SV)", width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad(ui.separator(40), width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("[s]  View Stats", width))
  table.insert(lines, ui.center_pad("[q]  Quit", width))
  table.insert(lines, "")

  -- Lifetime stats preview
  local stats = state.load_stats()
  if stats.sessions > 0 then
    local pct = stats.total_played > 0
      and math.floor((stats.total_correct / stats.total_played) * 100)
      or 0
    table.insert(lines, ui.center_pad(string.format("Sessions: %d  |  Accuracy: %d%%  |  Words practiced: %d",
      stats.sessions, pct, stats.total_played), width))
  end

  hl.clear(buf)
  ui.set_lines(buf, lines)

  -- Flag highlights (per-segment blue/yellow)
  for i, flag_line in ipairs(FLAG_LINES) do
    local line_idx = i - 1
    local rendered_line = lines[i]
    -- Find where the flag text starts within the centered line
    local pad = #rendered_line - #flag_line
    local segs = get_flag_highlights(line_idx)
    for _, seg in ipairs(segs) do
      hl.add_hl(buf, line_idx, pad + seg[1], pad + seg[2], seg[3])
    end
  end
  local base = #FLAG_LINES
  hl.add_hl(buf, base + 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, base + 2, 0, -1, "SvenskaSubtitle")
  hl.add_hl(buf, base + 5, 0, -1, "SvenskaTitle")

  -- Menu item highlights
  for i = base + 7, base + 9 do
    hl.add_hl(buf, i, 0, -1, "SvenskaMenuText")
  end

  if stats.sessions > 0 then
    hl.add_hl(buf, #lines - 1, 0, -1, "SvenskaProgress")
  end

  -- Keymaps
  local opts = { buffer = buf, nowait = true }
  vim.keymap.set("n", "1", function() M.show_category_menu("vocabulary") end, opts)
  vim.keymap.set("n", "2", function() M.show_category_menu("typing") end, opts)
  vim.keymap.set("n", "3", function() M.show_category_menu("translate") end, opts)
  vim.keymap.set("n", "s", function() M.show_stats() end, opts)
  vim.keymap.set("n", "q", function() M.quit() end, opts)
end

function M.show_category_menu(game_mode)
  state.mode = "category"
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = ui.create_buf()
    ui.show_buf(buf)
  end

  local width = vim.o.columns
  local is_sentence_mode = game_mode == "translate"

  local lines = {
    "",
    ui.center_pad("── Choose a Category ──", width),
    "",
  }

  local items = {}
  if is_sentence_mode then
    local levels = sentences_data.get_level_list()
    for i, lvl in ipairs(levels) do
      table.insert(items, { key = tostring(i), label = lvl.name, data_key = lvl.key, count = lvl.count })
      table.insert(lines, ui.center_pad(string.format("[%d]  %s  (%d sentences)", i, lvl.name, lvl.count), width))
    end
  else
    local categories = words_data.get_category_list()
    for i, cat in ipairs(categories) do
      table.insert(items, { key = tostring(i), label = cat.name, data_key = cat.key, count = cat.count })
      table.insert(lines, ui.center_pad(string.format("[%d]  %s  (%d words)", i, cat.name, cat.count), width))
    end
  end

  table.insert(lines, "")
  table.insert(lines, ui.center_pad("[a]  All categories mixed", width))

  if game_mode == "vocabulary" then
    table.insert(lines, "")
    table.insert(lines, ui.center_pad("DIRECTION", width))
    table.insert(lines, ui.center_pad("[d]  Toggle direction (current: " .. (state.direction == "sv_to_en" and "SV→EN" or "EN→SV") .. ")", width))
  end

  if game_mode == "translate" then
    table.insert(lines, "")
    table.insert(lines, ui.center_pad("DIRECTION", width))
    table.insert(lines, ui.center_pad("[d]  Toggle direction (current: " .. (state.direction == "sv_to_en" and "SV→EN" or "EN→SV") .. ")", width))
  end

  table.insert(lines, "")
  table.insert(lines, ui.center_pad("[b]  Back to menu", width))

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  for i = 3, 3 + #items - 1 do
    hl.add_hl(buf, i, 0, -1, "SvenskaMenuText")
  end

  -- Keymaps
  local opts = { buffer = buf, nowait = true }

  for _, item in ipairs(items) do
    vim.keymap.set("n", item.key, function()
      local data
      if is_sentence_mode then
        data = sentences_data.get_level_sentences(item.data_key)
      else
        data = words_data.get_category_words(item.data_key)
      end
      last_game = { mode = game_mode, items = data, direction = state.direction }
      M.start_game(game_mode, data)
    end, opts)
  end

  vim.keymap.set("n", "a", function()
    local data
    if is_sentence_mode then
      data = sentences_data.get_all_sentences()
    else
      data = words_data.get_all_words()
    end
    last_game = { mode = game_mode, items = data, direction = state.direction }
    M.start_game(game_mode, data)
  end, opts)

  vim.keymap.set("n", "d", function()
    state.direction = state.direction == "sv_to_en" and "en_to_sv" or "sv_to_en"
    M.show_category_menu(game_mode)
  end, opts)

  vim.keymap.set("n", "b", function()
    M.show_menu()
  end, opts)
end

function M.start_game(game_mode, items)
  if game_mode == "vocabulary" then
    require("svenska.modes.vocabulary").start(items, state.direction)
  elseif game_mode == "typing" then
    require("svenska.modes.typing").start(items)
  elseif game_mode == "translate" then
    require("svenska.modes.translate").start(items, state.direction)
  end
end

function M.replay()
  if last_game then
    M.start_game(last_game.mode, last_game.items)
  else
    M.show_menu()
  end
end

function M.show_stats()
  local buf = ui.create_buf()
  ui.show_buf(buf)

  local width = vim.o.columns
  local stats = state.load_stats()

  local pct = stats.total_played > 0
    and math.floor((stats.total_correct / stats.total_played) * 100)
    or 0

  local lines = {
    "",
    ui.center_pad("── Your Statistics ──", width),
    "",
    ui.center_pad(string.format("Sessions played: %d", stats.sessions), width),
    ui.center_pad(string.format("Total questions: %d", stats.total_played), width),
    ui.center_pad(string.format("Correct answers: %d", stats.total_correct), width),
    ui.center_pad(string.format("Wrong answers: %d", stats.total_wrong), width),
    ui.center_pad(string.format("Accuracy: %d%%", pct), width),
    "",
    ui.center_pad(ui.separator(40), width),
    "",
  }

  -- Most practiced words
  local word_counts = {}
  for word, count in pairs(stats.words_learned or {}) do
    table.insert(word_counts, { word = word, count = count })
  end
  table.sort(word_counts, function(a, b) return a.count > b.count end)

  if #word_counts > 0 then
    table.insert(lines, ui.center_pad("Most Practiced Words:", width))
    table.insert(lines, "")
    for i = 1, math.min(10, #word_counts) do
      local w = word_counts[i]
      table.insert(lines, ui.center_pad(string.format("%s  (%dx correct)", w.word, w.count), width))
    end
    table.insert(lines, "")
  end

  table.insert(lines, ui.center_pad("[m]  Back to menu   |   [q]  Quit", width))

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  for i = 3, 7 do
    hl.add_hl(buf, i, 0, -1, "SvenskaScore")
  end

  local opts = { buffer = buf, nowait = true }
  vim.keymap.set("n", "m", function() M.show_menu() end, opts)
  vim.keymap.set("n", "q", function() M.quit() end, opts)
end

function M.quit()
  ui.close_input()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state.buf = nil
  state.mode = "menu"
end

return M
