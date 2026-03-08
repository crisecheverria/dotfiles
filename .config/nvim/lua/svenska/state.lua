local M = {}

-- Session state
M.buf = nil
M.input_buf = nil
M.input_win = nil
M.mode = "menu" -- menu | category | playing | results
M.game_mode = nil -- vocabulary | typing | translate
M.current_items = {}
M.current_index = 0
M.correct = 0
M.wrong = 0
M.total = 0
M.answers = {}
M.category = nil
M.difficulty = nil
M.challenges_per_round = 10
M.direction = "sv_to_en" -- sv_to_en | en_to_sv

-- Stats persistence
local stats_path = vim.fn.stdpath("data") .. "/svenska_stats.json"

function M.reset_round()
  M.current_index = 0
  M.correct = 0
  M.wrong = 0
  M.total = 0
  M.answers = {}
end

function M.load_stats()
  local f = io.open(stats_path, "r")
  if not f then
    return { total_correct = 0, total_wrong = 0, total_played = 0, sessions = 0, words_learned = {} }
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and data then
    return data
  end
  return { total_correct = 0, total_wrong = 0, total_played = 0, sessions = 0, words_learned = {} }
end

function M.save_stats(stats)
  local dir = vim.fn.stdpath("data")
  vim.fn.mkdir(dir, "p")
  local f = io.open(stats_path, "w")
  if f then
    f:write(vim.json.encode(stats))
    f:close()
  end
end

function M.record_session()
  local stats = M.load_stats()
  stats.total_correct = stats.total_correct + M.correct
  stats.total_wrong = stats.total_wrong + M.wrong
  stats.total_played = stats.total_played + M.total
  stats.sessions = stats.sessions + 1
  -- Track words learned (answered correctly)
  for _, ans in ipairs(M.answers) do
    if ans.correct then
      stats.words_learned[ans.sv] = (stats.words_learned[ans.sv] or 0) + 1
    end
  end
  M.save_stats(stats)
end

return M
