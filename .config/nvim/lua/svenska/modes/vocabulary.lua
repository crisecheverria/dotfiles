local state = require("svenska.state")
local ui = require("svenska.ui")
local hl = require("svenska.highlight")

local M = {}

-- Forward declarations for mutual recursion
local render_challenge, show_feedback, next_challenge, check_answer, ask_answer

local function shuffle(t)
  local n = #t
  for i = n, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

render_challenge = function()
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local item = state.current_items[state.current_index]
  if not item then return end

  local width = vim.o.columns
  local is_sv_to_en = state.direction == "sv_to_en"
  local shown = is_sv_to_en and item.sv or item.en
  local direction_label = is_sv_to_en and "Swedish → English" or "English → Swedish"

  local lines = {
    "",
    ui.center_pad("── Vocabulary ──", width),
    "",
    ui.center_pad(direction_label, width),
    "",
    ui.center_pad("Translate this word:", width),
    "",
    ui.center_pad(shown, width),
    "",
    "",
    ui.center_pad(string.format("[ %d / %d ]  Correct: %d  Wrong: %d", state.current_index, state.total, state.correct, state.wrong), width),
    "",
    ui.center_pad("Type your answer in the input box below", width),
    ui.center_pad("Press <Esc> to quit", width),
  }

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, "SvenskaSubtitle")
  hl.add_hl(buf, 5, 0, -1, "SvenskaPrompt")
  hl.add_hl(buf, 7, 0, -1, is_sv_to_en and "SvenskaSwedish" or "SvenskaEnglish")
  hl.add_hl(buf, 10, 0, -1, "SvenskaProgress")
  hl.add_hl(buf, 13, 0, -1, "SvenskaHint")
end

show_feedback = function(is_correct, expected, given)
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local width = vim.o.columns
  local status = is_correct and "Correct!" or "Wrong!"
  local status_hl = is_correct and "SvenskaCorrect" or "SvenskaWrong"

  local item = state.current_items[state.current_index]
  local lines = {
    "",
    ui.center_pad("── Vocabulary ──", width),
    "",
    ui.center_pad(status, width),
    "",
    ui.center_pad(item.sv .. "  =  " .. item.en, width),
    "",
  }

  if not is_correct then
    table.insert(lines, ui.center_pad("Your answer: " .. given, width))
    table.insert(lines, ui.center_pad("Correct answer: " .. expected, width))
    table.insert(lines, "")
  end

  table.insert(lines, ui.center_pad(string.format("[ %d / %d ]  Correct: %d  Wrong: %d", state.current_index, state.total, state.correct, state.wrong), width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("Continuing in a moment...", width))

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, status_hl)
  hl.add_hl(buf, 5, 0, -1, "SvenskaSwedish")
end

ask_answer = function()
  local item = state.current_items[state.current_index]
  local is_sv_to_en = state.direction == "sv_to_en"
  local prompt = is_sv_to_en and ("Translate: " .. item.sv) or ("Translate: " .. item.en)
  ui.open_input(prompt, check_answer)
end

next_challenge = function()
  state.current_index = state.current_index + 1
  if state.current_index > state.total then
    state.record_session()
    require("svenska.modes.results").show()
    return
  end
  render_challenge()
  ask_answer()
end

check_answer = function(answer)
  if answer == nil then
    require("svenska").show_menu()
    return
  end

  local item = state.current_items[state.current_index]
  local is_sv_to_en = state.direction == "sv_to_en"
  local expected = is_sv_to_en and item.en or item.sv
  local normalized_answer = vim.trim(answer):lower()
  local normalized_expected = vim.trim(expected):lower()

  local is_correct = normalized_answer == normalized_expected

  if is_correct then
    state.correct = state.correct + 1
  else
    state.wrong = state.wrong + 1
  end

  table.insert(state.answers, {
    sv = item.sv,
    en = item.en,
    given = answer,
    correct = is_correct,
  })

  show_feedback(is_correct, expected, answer)

  vim.defer_fn(function()
    next_challenge()
  end, is_correct and 1000 or 2500)
end

function M.start(items, direction)
  state.reset_round()
  state.game_mode = "vocabulary"
  state.direction = direction or "sv_to_en"
  state.mode = "playing"

  local pool = {}
  for _, item in ipairs(items) do
    table.insert(pool, { sv = item.sv, en = item.en })
  end
  shuffle(pool)

  state.current_items = {}
  local count = math.min(state.challenges_per_round, #pool)
  for i = 1, count do
    table.insert(state.current_items, pool[i])
  end
  state.total = count

  local buf = ui.create_buf()
  ui.show_buf(buf)

  next_challenge()
end

return M
