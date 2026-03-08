local state = require("svenska.state")
local hl = require("svenska.highlight")

local M = {}

function M.create_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "svenska"
  state.buf = buf
  return buf
end

function M.show_buf(buf)
  vim.api.nvim_set_current_buf(buf)
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.wrap = true
  vim.wo.cursorline = false
end

function M.set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

function M.open_input(prompt, callback)
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    vim.api.nvim_win_close(state.input_win, true)
  end

  local width = math.max(50, #prompt + 10)
  local row = math.floor(vim.o.lines * 0.6)
  local col = math.floor((vim.o.columns - width) / 2)

  local input_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[input_buf].buftype = "nofile"
  state.input_buf = input_buf

  local win = vim.api.nvim_open_win(input_buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. prompt .. " ",
    title_pos = "center",
  })
  state.input_win = win

  vim.cmd("startinsert")

  vim.keymap.set("i", "<CR>", function()
    local lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
    local answer = lines[1] or ""
    vim.cmd("stopinsert")
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    state.input_win = nil
    state.input_buf = nil
    vim.schedule(function()
      callback(answer)
    end)
  end, { buffer = input_buf })

  vim.keymap.set("i", "<Esc>", function()
    vim.cmd("stopinsert")
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    state.input_win = nil
    state.input_buf = nil
    vim.schedule(function()
      callback(nil)
    end)
  end, { buffer = input_buf })
end

function M.close_input()
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    vim.api.nvim_win_close(state.input_win, true)
  end
  state.input_win = nil
  state.input_buf = nil
end

function M.center_pad(text, width)
  local pad = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
  if pad < 0 then pad = 0 end
  return string.rep(" ", pad) .. text
end

function M.separator(width)
  return string.rep("─", width)
end

return M
