local state = require("svenska.state")
local ui = require("svenska.ui")
local hl = require("svenska.highlight")

local M = {}

local function shuffle(t)
  local n = #t
  for i = n, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

local function render_challenge()
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
    ui.center_pad("── Sentence Translation ──", width),
    "",
    ui.center_pad(direction_label, width),
    "",
    ui.center_pad("Translate this sentence:", width),
    "",
    ui.center_pad(shown, width),
    "",
    "",
    ui.center_pad(string.format("[ %d / %d ]  Correct: %d  Wrong: %d", state.current_index, state.total, state.correct, state.wrong), width),
    "",
    ui.center_pad("Press <Esc> to quit", width),
  }

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, "SvenskaSubtitle")
  hl.add_hl(buf, 5, 0, -1, "SvenskaPrompt")
  hl.add_hl(buf, 7, 0, -1, is_sv_to_en and "SvenskaSwedish" or "SvenskaEnglish")
  hl.add_hl(buf, 10, 0, -1, "SvenskaProgress")
  hl.add_hl(buf, 12, 0, -1, "SvenskaHint")
end

local function show_feedback(is_correct, expected, given)
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local width = vim.o.columns
  local status = is_correct and "Correct!" or "Not quite..."
  local status_hl = is_correct and "SvenskaCorrect" or "SvenskaWrong"

  local item = state.current_items[state.current_index]
  local lines = {
    "",
    ui.center_pad("── Sentence Translation ──", width),
    "",
    ui.center_pad(status, width),
    "",
    ui.center_pad(item.sv, width),
    ui.center_pad("=", width),
    ui.center_pad(item.en, width),
    "",
  }

  if not is_correct then
    table.insert(lines, ui.center_pad("Your answer: " .. given, width))
    table.insert(lines, ui.center_pad("Expected: " .. expected, width))
    table.insert(lines, "")
  end

  table.insert(lines, ui.center_pad(string.format("[ %d / %d ]  Correct: %d  Wrong: %d", state.current_index, state.total, state.correct, state.wrong), width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("Continuing...", width))

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, status_hl)
  hl.add_hl(buf, 5, 0, -1, "SvenskaSwedish")
  hl.add_hl(buf, 7, 0, -1, "SvenskaEnglish")
end

local function ask_input()
  local item = state.current_items[state.current_index]
  local is_sv_to_en = state.direction == "sv_to_en"
  local prompt = is_sv_to_en and "English translation" or "Swedish translation"
  ui.open_input(prompt, function(answer)
    if answer == nil then
      require("svenska").show_menu()
      return
    end

    local expected = is_sv_to_en and item.en or item.sv
    local normalized_answer = vim.trim(answer):lower()
    local normalized_expected = vim.trim(expected):lower()

    -- Strip trailing period for comparison flexibility
    normalized_answer = normalized_answer:gsub("%.$", "")
    normalized_expected = normalized_expected:gsub("%.$", "")

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
      state.current_index = state.current_index + 1
      if state.current_index > state.total then
        state.record_session()
        require("svenska.modes.results").show()
        return
      end
      render_challenge()
      ask_input()
    end, is_correct and 1000 or 3000)
  end)
end

function M.start(items, direction)
  state.reset_round()
  state.game_mode = "translate"
  state.direction = direction or "en_to_sv"
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

  state.current_index = 1
  render_challenge()
  ask_input()
end

return M
