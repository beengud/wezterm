local Utils = require "utils"
local color = Utils.fn.color

---@diagnostic disable-next-line: undefined-field
local G = require("wezterm").GLOBAL

local Config = {}

Config.color_schemes = color.get_schemes()
Config.color_scheme = "slime"

local theme = Config.color_schemes[Config.color_scheme]
if not theme then
  -- Fallback to a built-in scheme if custom scheme fails to load
  local wt = require("wezterm")
  wt.log_error("Failed to load color scheme: " .. tostring(Config.color_scheme))
  Config.color_scheme = "Bamboo"  -- fallback
  theme = wt.color.get_builtin_schemes()[Config.color_scheme]
end

-- Apply colors directly from the theme
Config.colors = {
  foreground = theme.foreground,
  background = theme.background,
  cursor_bg = theme.cursor_bg,
  cursor_fg = theme.cursor_fg,
  cursor_border = theme.cursor_border,
  selection_fg = theme.selection_fg,
  selection_bg = theme.selection_bg,
  scrollbar_thumb = theme.scrollbar_thumb,
  split = theme.split,
  ansi = theme.ansi,
  brights = theme.brights,
  indexed = theme.indexed,
  compose_cursor = theme.compose_cursor,
  visual_bell = theme.visual_bell,
  copy_mode_active_highlight_bg = theme.copy_mode_active_highlight_bg,
  copy_mode_active_highlight_fg = theme.copy_mode_active_highlight_fg,
  copy_mode_inactive_highlight_bg = theme.copy_mode_inactive_highlight_bg,
  copy_mode_inactive_highlight_fg = theme.copy_mode_inactive_highlight_fg,
  quick_select_label_bg = theme.quick_select_label_bg,
  quick_select_label_fg = theme.quick_select_label_fg,
  quick_select_match_bg = theme.quick_select_match_bg,
  quick_select_match_fg = theme.quick_select_match_fg,
  tab_bar = theme.tab_bar,
}

Config.background = {
  {
    source = { Color = theme.background },
    width = "100%",
    height = "100%",
    opacity = G.opacity or 1,
  },
}

Config.bold_brightens_ansi_colors = "BrightAndBold"

---char select and command palette
Config.char_select_bg_color = theme.brights[6]
Config.char_select_fg_color = theme.background
Config.char_select_font_size = 12

Config.command_palette_bg_color = theme.brights[6]
Config.command_palette_fg_color = theme.background
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

---window appearance
Config.window_padding = { left = 2, right = 2, top = 2, bottom = 1 }
Config.integrated_title_button_alignment = "Right"
Config.integrated_title_button_style = "Windows"
Config.integrated_title_buttons = { "Hide", "Maximize", "Close" }

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
Config.window_close_confirmation = "AlwaysPrompt"

color.set_tab_button(Config, theme)

return Config
