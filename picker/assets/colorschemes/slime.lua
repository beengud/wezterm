---Ported from: https://github.com/beengud/theme-slime
---@module "picker.assets.colorschemes.slime"
---@author beengud
---@license GNU-GPLv3

---@class PickList
local M = {}

local color = require("utils").fn.color

M.scheme = {
  background = "#1e2324",
  foreground = "#e0e0e0",
  cursor_bg = "#a8df5a",
  cursor_fg = "#1e2324",
  cursor_border = "#a8df5a",
  selection_fg = "#e0e0e0",
  selection_bg = "rgba(108, 81, 110, 0.44)",  -- #6c516e with 70 = ~44% opacity
  scrollbar_thumb = "#405c50",
  split = "#375d4f",
  ansi = {
    "#666666",  -- Black
    "#cd6564",  -- Red
    "#AEC199",  -- Green
    "#fff099",  -- Yellow
    "#6D9CBE",  -- Blue
    "#B081B9",  -- Magenta
    "#80B5B3",  -- Cyan
    "#efefef",  -- White
  },
  brights = {
    "#666666",  -- Bright Black
    "#cd6564",  -- Bright Red
    "#AEC199",  -- Bright Green
    "#fff099",  -- Bright Yellow
    "#6D9CBE",  -- Bright Blue
    "#B081B9",  -- Bright Magenta
    "#80B5B3",  -- Bright Cyan
    "#efefef",  -- Bright White
  },
  indexed = {},
  compose_cursor = "#a8df5a",
  visual_bell = "#405c50",
  copy_mode_active_highlight_bg = { Color = "#405c50" },
  copy_mode_active_highlight_fg = { Color = "#e0e0e0" },
  copy_mode_inactive_highlight_bg = { Color = "#2F6260" },
  copy_mode_inactive_highlight_fg = { Color = "#e0e0e0" },
  quick_select_label_bg = { Color = "#cd6564" },
  quick_select_label_fg = { Color = "#e0e0e0" },
  quick_select_match_bg = { Color = "#fff099" },
  quick_select_match_fg = { Color = "#1e2324" },
  tab_bar = {
    background = "#282e2f",
    inactive_tab_edge = "#222",
    active_tab = { bg_color = "#a8df5a", fg_color = "#1e2324", italic = false },
    inactive_tab = { bg_color = "#282e2f", fg_color = "#878f8c", italic = false },
    inactive_tab_hover = { bg_color = "#405c50", fg_color = "#e0e0e0", italic = false },
    new_tab = { bg_color = "#2F6260", fg_color = "#e0e0e0", italic = false },
    new_tab_hover = { bg_color = "#375d4f", fg_color = "#e0e0e0", italic = false },
  },
}

function M.get()
  return { id = "slime", label = "Slime" }
end

function M.activate(Config, callback_opts)
  local theme = M.scheme
  color.set_scheme(Config, theme, callback_opts.id)
end

return M
