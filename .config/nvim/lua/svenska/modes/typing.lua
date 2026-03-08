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
  -- Show both the Swedish text and its English meaning
  local lines = {
    "",
    ui.center_pad("── Typing Practice ──", width),
    "",
    ui.center_pad("Type the Swedish text exactly as shown:", width),
    "",
    ui.center_pad(item.sv, width),
    "",
    ui.center_pad("(" .. item.en .. ")", width),
    "",
    "",
    ui.center_pad(string.format("[ %d / %d ]  Correct: %d  Wrong: %d", state.current_index, state.total, state.correct, state.wrong), width),
    "",
    ui.center_pad("Press <Esc> to quit", width),
  }

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, "SvenskaPrompt")
  hl.add_hl(buf, 5, 0, -1, "SvenskaSwedish")
  hl.add_hl(buf, 7, 0, -1, "SvenskaEnglish")
  hl.add_hl(buf, 10, 0, -1, "SvenskaProgress")
  hl.add_hl(buf, 12, 0, -1, "SvenskaHint")
end

local function show_feedback(is_correct, expected, given)
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local width = vim.o.columns
  local status = is_correct and "Perfect!" or "Not quite..."
  local status_hl = is_correct and "SvenskaCorrect" or "SvenskaWrong"

  local lines = {
    "",
    ui.center_pad("── Typing Practice ──", width),
    "",
    ui.center_pad(status, width),
    "",
  }

  if not is_correct then
    table.insert(lines, ui.center_pad("Expected: " .. expected, width))
    table.insert(lines, ui.center_pad("You typed: " .. given, width))
    table.insert(lines, "")
  else
    table.insert(lines, ui.center_pad(expected, width))
    table.insert(lines, "")
  end

  table.insert(lines, ui.center_pad(string.format("[ %d / %d ]  Correct: %d  Wrong: %d", state.current_index, state.total, state.correct, state.wrong), width))
  table.insert(lines, "")
  table.insert(lines, ui.center_pad("Continuing...", width))

  hl.clear(buf)
  ui.set_lines(buf, lines)

  hl.add_hl(buf, 1, 0, -1, "SvenskaTitle")
  hl.add_hl(buf, 3, 0, -1, status_hl)
end

local function ask_input()
  local item = state.current_items[state.current_index]
  ui.open_input("Type: " .. item.sv, function(answer)
    if answer == nil then
      require("svenska").show_menu()
      return
    end

    local expected = item.sv
    local is_correct = answer == expected

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
    end, is_correct and 800 or 2000)
  end)
end

function M.start(items)
  state.reset_round()
  state.game_mode = "typing"
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
