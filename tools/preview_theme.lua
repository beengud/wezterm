#!/usr/bin/env lua
---@module "tools.preview_theme"
---Interactive theme color preview tool
---Usage: lua tools/preview_theme.lua [theme_name]

-- Add project paths
local script_dir = arg[0]:match("(.*)/")
local config_dir = script_dir and script_dir:gsub("/tools$", "") or "."
package.path = string.format(
  "%s/?.lua;%s/?/init.lua;%s",
  config_dir,
  config_dir,
  package.path
)

-- Get theme name from args
local theme_name = arg[1] or "slime"

-- Mock WezTerm for standalone use
package.loaded.wezterm = {
  GLOBAL = {},
  config_dir = config_dir,
  color = {
    parse = function(color)
      return {
        darken = function(self) return self end,
        lighten = function(self) return self end,
      }
    end
  },
  log_info = function(...) print(string.format(...)) end,
  log_warn = function(...) print("WARN: " .. string.format(...)) end,
  log_error = function(...) print("ERROR: " .. string.format(...)) end,
}

-- ANSI color codes for terminal output
local ansi = {
  reset = "\27[0m",
  bold = "\27[1m",
  black = "\27[30m",
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  blue = "\27[34m",
  magenta = "\27[35m",
  cyan = "\27[36m",
  white = "\27[37m",
  bg_black = "\27[40m",
  bg_red = "\27[41m",
  bg_green = "\27[42m",
  bg_yellow = "\27[43m",
  bg_blue = "\27[44m",
  bg_magenta = "\27[45m",
  bg_cyan = "\27[46m",
  bg_white = "\27[47m",
}

-- Load the theme
local function load_theme(name)
  local module_path = "picker.assets.colorschemes." .. name
  local success, module = pcall(require, module_path)

  if not success then
    print(ansi.red .. "Error: Could not load theme '" .. name .. "'" .. ansi.reset)
    print("Module path: " .. module_path)
    print("Error: " .. tostring(module))
    os.exit(1)
  end

  return module
end

-- Convert hex to RGB
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  if #hex == 3 then
    hex = hex:gsub("(.)", "%1%1")
  end
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  return r, g, b
end

-- Create ANSI color escape for RGB
local function rgb_color(hex, is_bg)
  if type(hex) ~= "string" or not hex:match("^#") then
    return ""
  end
  local r, g, b = hex_to_rgb(hex)
  if not r then return "" end
  local code = is_bg and 48 or 38
  return string.format("\27[%d;2;%d;%d;%dm", code, r, g, b)
end

-- Print colored block
local function print_color_block(name, color, width)
  width = width or 20
  local fg_code = rgb_color(color, false)
  local bg_code = rgb_color(color, true)

  if fg_code ~= "" and bg_code ~= "" then
    print(string.format(
      "%-16s %s%-8s%s %s%s%s",
      name,
      ansi.bold,
      color,
      ansi.reset,
      bg_code,
      string.rep(" ", width),
      ansi.reset
    ))
  else
    print(string.format("%-16s %-8s (invalid color format)", name, tostring(color)))
  end
end

-- Main preview function
local function preview_theme(theme_name)
  local module = load_theme(theme_name)
  local theme = module.scheme
  local info = module.get()

  print(ansi.bold .. ansi.cyan .. "\n╔════════════════════════════════════════════════════════╗" .. ansi.reset)
  print(ansi.bold .. ansi.cyan .. "║  Theme Preview: " .. info.label .. string.rep(" ", 37 - #info.label) .. "║" .. ansi.reset)
  print(ansi.bold .. ansi.cyan .. "╚════════════════════════════════════════════════════════╝" .. ansi.reset)

  print(ansi.bold .. "\n📐 Main Colors:" .. ansi.reset)
  print_color_block("Background", theme.background)
  print_color_block("Foreground", theme.foreground)
  print_color_block("Cursor", theme.cursor_bg)
  print_color_block("Selection", theme.selection_bg)

  print(ansi.bold .. "\n🎨 ANSI Colors (0-7):" .. ansi.reset)
  local ansi_names = {"Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White"}
  for i = 1, 8 do
    print_color_block(ansi_names[i], theme.ansi[i])
  end

  print(ansi.bold .. "\n✨ Bright Colors (8-15):" .. ansi.reset)
  local bright_names = {"Bright Black", "Bright Red", "Bright Green", "Bright Yellow",
                        "Bright Blue", "Bright Magenta", "Bright Cyan", "Bright White"}
  for i = 1, 8 do
    print_color_block(bright_names[i], theme.brights[i])
  end

  print(ansi.bold .. "\n🪟 Tab Bar:" .. ansi.reset)
  print_color_block("Background", theme.tab_bar.background)
  if theme.tab_bar.active_tab then
    print_color_block("Active Tab BG", theme.tab_bar.active_tab.bg_color)
    print_color_block("Active Tab FG", theme.tab_bar.active_tab.fg_color)
  end
  if theme.tab_bar.inactive_tab then
    print_color_block("Inactive Tab BG", theme.tab_bar.inactive_tab.bg_color)
  end

  print("\n" .. ansi.bold .. "✓ Theme loaded successfully!" .. ansi.reset)
  print("ID: " .. info.id)
  print("Label: " .. info.label .. "\n")
end

-- Run the preview
preview_theme(theme_name)
