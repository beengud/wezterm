#!/usr/bin/env lua
---@module "tools.validate_theme_standalone"
---Standalone theme validation that doesn't require full WezTerm environment
---Usage: lua tools/validate_theme_standalone.lua [theme_name]

local theme_name = arg[1] or "slime"

-- Validation functions
local function is_valid_hex_color(color)
  if type(color) ~= "string" then
    return false
  end
  return color:match("^#[0-9a-fA-F]+$") ~= nil
end

local function is_valid_color(color)
  if type(color) == "string" then
    return color:match("^#[0-9a-fA-F]+$") ~= nil
        or color:match("^rgba%(") ~= nil
        or color:match("^[a-z]+$") ~= nil
  elseif type(color) == "table" and color.Color then
    return is_valid_color(color.Color)
  end
  return false
end

local function validate_theme(theme, theme_name)
  local errors = {}

  -- Check required fields
  local required_fields = {
    "background", "foreground", "cursor_bg", "cursor_fg", "cursor_border",
    "selection_fg", "selection_bg", "ansi", "brights", "tab_bar"
  }

  for _, field in ipairs(required_fields) do
    if theme[field] == nil then
      table.insert(errors, "Missing required field: " .. field)
    end
  end

  -- Check ANSI colors
  if theme.ansi then
    if #theme.ansi ~= 8 then
      table.insert(errors, "ansi must have 8 colors, got " .. #theme.ansi)
    else
      for i, color in ipairs(theme.ansi) do
        if not is_valid_color(color) then
          table.insert(errors, string.format("ansi[%d] invalid color: %s", i, tostring(color)))
        end
      end
    end
  end

  -- Check bright colors
  if theme.brights then
    if #theme.brights ~= 8 then
      table.insert(errors, "brights must have 8 colors, got " .. #theme.brights)
    else
      for i, color in ipairs(theme.brights) do
        if not is_valid_color(color) then
          table.insert(errors, string.format("brights[%d] invalid color: %s", i, tostring(color)))
        end
      end
    end
  end

  -- Check tab_bar
  if theme.tab_bar then
    if type(theme.tab_bar) ~= "table" then
      table.insert(errors, "tab_bar must be a table")
    else
      local tab_required = {"background", "active_tab", "inactive_tab", "new_tab"}
      for _, field in ipairs(tab_required) do
        if theme.tab_bar[field] == nil then
          table.insert(errors, "tab_bar missing: " .. field)
        end
      end
    end
  end

  return errors
end

-- Load theme file directly (without require, to avoid dependencies)
local function load_theme_file(name)
  local filename = string.format("picker/assets/colorschemes/%s.lua", name)
  local file = io.open(filename, "r")
  if not file then
    print("❌ Error: Could not open file: " .. filename)
    os.exit(1)
  end

  local content = file:read("*all")
  file:close()

  -- Extract scheme table manually (simple parsing)
  local scheme = {}

  -- Parse main colors
  scheme.background = content:match('background%s*=%s*"(#[^"]+)"')
  scheme.foreground = content:match('foreground%s*=%s*"(#[^"]+)"')
  scheme.cursor_bg = content:match('cursor_bg%s*=%s*"(#[^"]+)"')
  scheme.cursor_fg = content:match('cursor_fg%s*=%s*"(#[^"]+)"')
  scheme.cursor_border = content:match('cursor_border%s*=%s*"(#[^"]+)"')
  scheme.selection_fg = content:match('selection_fg%s*=%s*"(#[^"]+)"')
  scheme.selection_bg = content:match('selection_bg%s*=%s*"(#[^"]+)"')

  -- Parse ANSI colors
  scheme.ansi = {}
  for color in content:gmatch('ansi%s*=%s*{[^}]*"(#[^"]+)"') do
    table.insert(scheme.ansi, color)
  end
  if #scheme.ansi == 0 then
    -- Try alternative pattern with comments
    local ansi_block = content:match('ansi%s*=%s*{([^}]+)}')
    if ansi_block then
      for color in ansi_block:gmatch('"(#[0-9a-fA-F]+)"') do
        table.insert(scheme.ansi, color)
      end
    end
  end

  -- Parse bright colors
  scheme.brights = {}
  local brights_block = content:match('brights%s*=%s*{([^}]+)}')
  if brights_block then
    for color in brights_block:gmatch('"(#[0-9a-fA-F]+)"') do
      table.insert(scheme.brights, color)
    end
  end

  -- Tab bar (just check existence)
  scheme.tab_bar = {}
  if content:match('tab_bar%s*=%s*{') then
    scheme.tab_bar.background = content:match('tab_bar.-background%s*=%s*"(#[^"]+)"')
    scheme.tab_bar.active_tab = content:match('active_tab') and {} or nil
    scheme.tab_bar.inactive_tab = content:match('inactive_tab') and {} or nil
    scheme.tab_bar.new_tab = content:match('new_tab') and {} or nil
  end

  return scheme
end

-- Main validation
print(string.format("\n🔍 Validating theme: %s\n", theme_name))

local theme = load_theme_file(theme_name)
local errors = validate_theme(theme, theme_name)

if #errors == 0 then
  print("✅ Theme validation PASSED!")
  print(string.format("   • Background: %s", theme.background or "missing"))
  print(string.format("   • Foreground: %s", theme.foreground or "missing"))
  print(string.format("   • Cursor: %s", theme.cursor_bg or "missing"))
  print(string.format("   • ANSI colors: %d/8", #theme.ansi))
  print(string.format("   • Bright colors: %d/8", #theme.brights))
  print(string.format("   • Tab bar: %s", theme.tab_bar.background and "present" or "missing"))
  print("\n✓ Theme is ready to use!\n")
  os.exit(0)
else
  print("❌ Theme validation FAILED!\n")
  for i, err in ipairs(errors) do
    print(string.format("   %d. %s", i, err))
  end
  print("\n")
  os.exit(1)
end
