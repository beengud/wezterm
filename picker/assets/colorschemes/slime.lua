---Ported from: smlombardi.slime VSCode theme
---@module "picker.assets.colorschemes.slime"
---@author sravioli
---@license GNU-GPLv3

---@class PickList
local M = {}

local color = require("utils").fn.color

M.scheme = {
  -- Main colors from VSCode Slime theme
  background = "#1e2324",
  foreground = "#e0e0e0",
  cursor_bg = "#a8df5a",
  cursor_fg = "#1e2324",
  cursor_border = "#a8df5a",
  selection_fg = "#e0e0e0",
  selection_bg = "#6c516e",
  scrollbar_thumb = "#bcbebe",
  split = "#293030",
  ansi = {
    "#666666",    -- black
    "#cd6564",    -- red
    "#AEC199",    -- green
    "#fff099",    -- yellow
    "#6D9CBE",    -- blue
    "#B081B9",    -- magenta
    "#80B5B3",    -- cyan
    "#efefef",    -- white
  },
  brights = {
    "#666666",    -- bright black
    "#cd6564",    -- bright red
    "#AEC199",    -- bright green
    "#fff099",    -- bright yellow
    "#6D9CBE",    -- bright blue
    "#B081B9",    -- bright magenta
    "#80B5B3",    -- bright cyan
    "#efefef",    -- bright white
  },
  indexed = {},
  compose_cursor = "#a8df5a",
  visual_bell = "#687F7B",
  copy_mode_active_highlight_bg = { Color = "#6c516e" },
  copy_mode_active_highlight_fg = { Color = "#e0e0e0" },
  copy_mode_inactive_highlight_bg = { Color = "#687F7B" },
  copy_mode_inactive_highlight_fg = { Color = "#bcbebe" },
  quick_select_label_bg = { Color = "#AEC199" },
  quick_select_label_fg = { Color = "#1e2324" },
  quick_select_match_bg = { Color = "#6D9CBE" },
  quick_select_match_fg = { Color = "#e0e0e0" },
  tab_bar = {
    background = "#1b2020",
    inactive_tab_edge = "#293030",
    active_tab = { bg_color = "#1e2324", fg_color = "#e0e0e0", italic = false },
    inactive_tab = { bg_color = "#293030", fg_color = "#62706a" },
    inactive_tab_hover = { bg_color = "#3a4040", fg_color = "#bcbebe", italic = true },
    new_tab = { bg_color = "#293030", fg_color = "#62706a" },
    new_tab_hover = { bg_color = "#3a4040", fg_color = "#bcbebe", italic = true },
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
