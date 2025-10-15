local Utils = require "utils"
local color = Utils.fn.color

---@diagnostic disable-next-line: undefined-field
local G = require("wezterm").GLOBAL

local Config = {}

-- Load all custom color schemes into the color_schemes table
Config.color_schemes = color.get_schemes()

-- Get the slime theme
local theme = Config.color_schemes["slime"]
if not theme then
  -- Fallback to a built-in scheme if custom scheme fails to load
  local wt = require("wezterm")
  wt.log_error("Failed to load slime color scheme, falling back to Bamboo")
  Config.color_scheme = "Bamboo"
  theme = wt.color.get_builtin_schemes()["Bamboo"]
else
  local wt = require("wezterm")
  wt.log_info("=== SLIME THEME LOADING ===")
  wt.log_info("Loaded slime color scheme. Background: " .. tostring(theme.background))
  wt.log_info("Foreground: " .. tostring(theme.foreground))

  -- Set the color scheme name so event handlers can find it
  Config.color_scheme = "slime"
  wt.log_info("Set Config.color_scheme to: " .. tostring(Config.color_scheme))

  -- Directly set all colors - this takes priority in modern WezTerm
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

  -- Set char_select colors (using slime green accent)
  Config.char_select_bg_color = theme.ansi[3]  -- AEC199 (green)
  Config.char_select_fg_color = theme.background

  -- Set command_palette colors (using slime dark background with green accents)
  Config.command_palette_bg_color = theme.tab_bar.background  -- #1b2020 (darker bg)
  Config.command_palette_fg_color = theme.foreground  -- #e0e0e0 (light text)

  -- Set tab button styling
  color.set_tab_button(Config, theme)

  wt.log_info("Config.colors.background set to: " .. tostring(Config.colors.background))
  wt.log_info("=== END SLIME THEME LOADING ===")
end

Config.bold_brightens_ansi_colors = "BrightAndBold"

-- Override font sizes and rows for char_select and command_palette
Config.char_select_font_size = 12
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
Config.window_background_opacity = 0.75
Config.integrated_title_button_alignment = "Right"
Config.integrated_title_button_style = "Windows"
Config.integrated_title_buttons = { "Hide", "Maximize", "Close" }

---exit behavior
Config.clean_exit_codes = { 130 }
Config.exit_behavior = "Close"  -- Always close without confirmation
Config.exit_behavior_messaging = "None"  -- No messages
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
Config.window_close_confirmation = "NeverPrompt"  -- Never ask for confirmation

-- Note: set_tab_button() is already called by color.set_scheme() above

return Config
