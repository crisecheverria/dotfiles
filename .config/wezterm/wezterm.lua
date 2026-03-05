local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ==========================================================================
-- Font
-- ==========================================================================
config.font = wezterm.font_with_fallback({
  { family = "Lilex Nerd Font", weight = "Regular" },
  "Symbols Nerd Font",
  "Apple Color Emoji",
})
config.font_size = 14
config.line_height = 1.1

-- ==========================================================================
-- Theme & Colors (Tokyo Night)
-- ==========================================================================
config.color_scheme = "Tokyo Night"

-- ==========================================================================
-- Window / Appearance
-- ==========================================================================
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.max_fps = 120
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.65,
}

-- ==========================================================================
-- Cursor
-- ==========================================================================
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ==========================================================================
-- Scrollback & Mouse
-- ==========================================================================
config.scrollback_lines = 10000
config.hide_mouse_cursor_when_typing = true

-- ==========================================================================
-- Tab Bar
-- ==========================================================================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

config.colors = {
  tab_bar = {
    background = "#1a1b26",
    active_tab = {
      bg_color = "#7aa2f7",
      fg_color = "#1a1b26",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#24283b",
      fg_color = "#565f89",
    },
    inactive_tab_hover = {
      bg_color = "#292e42",
      fg_color = "#c0caf5",
    },
  },
}

-- ==========================================================================
-- Leader Key (tmux-style Ctrl+a)
-- ==========================================================================
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 }

-- ==========================================================================
-- Key Bindings
-- ==========================================================================
config.keys = {
  -- Pane splitting
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation (vim-style)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Pane zoom & close
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  -- Tab management
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  -- Switch to tab by number
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

  -- Clear scrollback
  { key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

  -- Search
  { key = "f", mods = "CMD", action = act.Search({ CaseInSensitiveString = "" }) },

  -- Send Ctrl+a through to the terminal (press leader twice)
  { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
}

-- ==========================================================================
-- Multiplexing (unix domain for session persistence)
-- ==========================================================================
config.unix_domains = {
  { name = "unix" },
}

-- ==========================================================================
-- Status Bar
-- ==========================================================================
wezterm.on("update-status", function(window, pane)
  -- Left status: workspace + leader indicator
  local leader = window:leader_is_active() and "  LDR " or ""
  local workspace = window:active_workspace()

  window:set_left_status(wezterm.format({
    { Foreground = { Color = "#1a1b26" } },
    { Background = { Color = "#bb9af7" } },
    { Text = " " .. workspace .. " " },
    { Foreground = { Color = "#1a1b26" } },
    { Background = { Color = "#e0af68" } },
    { Text = leader },
    "ResetAttributes",
  }))

  -- Right status: cwd + date/time
  local cwd_uri = pane:get_current_working_dir()
  local cwd = ""
  if cwd_uri then
    local path = cwd_uri.file_path
    cwd = path and path:gsub("^" .. os.getenv("HOME"), "~") or ""
  end

  local date = wezterm.strftime("%a %b %-d  %H:%M")

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#a9b1d6" } },
    { Background = { Color = "#24283b" } },
    { Text = " " .. cwd .. " " },
    { Foreground = { Color = "#1a1b26" } },
    { Background = { Color = "#7aa2f7" } },
    { Text = " " .. date .. " " },
  }))
end)

-- ==========================================================================
-- Tab Title (process name + cwd)
-- ==========================================================================
wezterm.on("format-tab-title", function(tab)
  local pane = tab.active_pane
  local title = pane.foreground_process_name:match("([^/]+)$") or ""

  local cwd_uri = pane.current_working_dir
  local dir = ""
  if cwd_uri then
    local path = cwd_uri.file_path
    if path then
      dir = path:match("([^/]+)$") or ""
    end
  end

  if dir ~= "" and title ~= "" then
    title = title .. " " .. dir
  elseif dir ~= "" then
    title = dir
  end

  local index = tab.tab_index + 1
  return " " .. index .. ": " .. title .. " "
end)

return config
