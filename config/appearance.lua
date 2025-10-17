local Utils = require "utils"
local color = Utils.fn.color

---@diagnostic disable-next-line: undefined-field
local G = require("wezterm").GLOBAL

local Config = {}

Config.color_schemes = color.get_schemes()
Config.color_scheme = color.get_scheme()

local theme = Config.color_schemes[Config.color_scheme]

Config.background = {
  {
    source = { Color = theme.background },
    width = "100%",
    height = "100%",
    opacity = 0.75,
  },
}

Config.window_background_opacity = 0.75

Config.bold_brightens_ansi_colors = "BrightAndBold"

---char select and command palette (using Slime theme colors)
Config.char_select_bg_color = "#405c50"  -- Slime green-gray
Config.char_select_fg_color = "#e0e0e0"  -- Slime foreground
Config.char_select_font_size = 12

Config.command_palette_bg_color = "#2F6260"  -- Slime button background
Config.command_palette_fg_color = "#e0e0e0"  -- Slime foreground
Config.command_palette_font_size = 14
Config.command_palette_rows = 20

---cursor
Config.cursor_blink_ease_in = "EaseIn"
Config.cursor_blink_ease_out = "EaseOut"
Config.cursor_blink_rate = 500
Config.default_cursor_style = "BlinkingUnderline"
Config.cursor_thickness = 1
Config.force_reverse_video_cursor = true

Config.enable_scroll_bar = true

Config.hide_mouse_cursor_when_typing = true

---text blink
Config.text_blink_ease_in = "EaseIn"
Config.text_blink_ease_out = "EaseOut"
Config.text_blink_rapid_ease_in = "Linear"
Config.text_blink_rapid_ease_out = "Linear"
Config.text_blink_rate = 500
Config.text_blink_rate_rapid = 250

---visual bell
Config.audible_bell = "SystemBeep"
Config.visual_bell = {
  fade_in_function = "EaseOut",
  fade_in_duration_ms = 200,
  fade_out_function = "EaseIn",
  fade_out_duration_ms = 200,
}

---window appearance (Slime theme colors)
Config.window_padding = { left = 2, right = 2, top = 2, bottom = 1 }
Config.integrated_title_button_alignment = "Right"
Config.integrated_title_button_style = "Windows"
Config.integrated_title_buttons = { "Hide", "Maximize", "Close" }

-- Window frame colors for Slime theme
Config.window_frame = {
  active_titlebar_bg = "#282e2f",  -- Slime tab bar background
  inactive_titlebar_bg = "#1e2324",  -- Slime background
  active_titlebar_fg = "#e0e0e0",  -- Slime foreground
  inactive_titlebar_fg = "#878f8c",  -- Slime inactive tab foreground
  button_bg = "#2F6260",  -- Slime button background
  button_fg = "#e0e0e0",  -- Slime foreground
  button_hover_bg = "#405c50",  -- Slime hover background
  button_hover_fg = "#e0e0e0",  -- Slime foreground
}

-- Pane selection colors for Slime theme
Config.pane_select_bg_color = "#2F6260"  -- Slime button background
Config.pane_select_fg_color = "#a8df5a"  -- Slime cursor (bright green)

-- Split/pane border colors
Config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}

-- Color for split borders
Config.colors = {
  split = "#375d4f",  -- Slime split color
  scrollbar_thumb = "#405c50",  -- Slime scrollbar
}

---exit behavior
Config.clean_exit_codes = { 130 }
Config.exit_behavior = "CloseOnCleanExit"
Config.exit_behavior_messaging = "Verbose"
Config.skip_close_confirmation_for_processes_named = {
  "bash",
  "sh",
  "zsh",
  "fish",
  "tmux",
  "nu",
  "cmd.exe",
  "pwsh.exe",
  "powershell.exe",
}
Config.window_close_confirmation = "NeverPrompt"

color.set_tab_button(Config, theme)

return Config
