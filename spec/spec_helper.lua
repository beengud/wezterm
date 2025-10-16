---@module "spec.spec_helper"
---Test helper utilities and shared setup for Busted tests

-- Add project paths to Lua search path
local config_dir = os.getenv("PWD") or "."
package.path = string.format(
  "%s/?.lua;%s/?/init.lua;%s",
  config_dir,
  config_dir,
  package.path
)

local helper = {}

---Mock WezTerm module for testing
---@return table wezterm_mock
function helper.mock_wezterm()
  -- Mock nerdfonts module that icon.lua depends on
  package.loaded.wezterm_nerdfonts = setmetatable({}, {
    __index = function(t, k)
      -- Return mock icon strings for any nerdfonts access
      return ""
    end
  })

  return {
    GLOBAL = {},
    config_dir = config_dir,
    config_builder = function()
      return {
        set_strict_mode = function() end
      }
    end,
    color = {
      parse = function(color)
        return {
          darken = function(self, amount) return self end,
          lighten = function(self, amount) return self end,
        }
      end
    },
    log_info = function(...) end,
    log_warn = function(...) end,
    log_error = function(...) end,
    nerdfonts = setmetatable({}, {
      __index = function(t, k)
        return ""
      end
    })
  }
end

---Validate hex color format
---@param color string
---@return boolean is_valid
function helper.is_valid_hex_color(color)
  if type(color) ~= "string" then
    return false
  end
  -- Check for #RRGGBB or #RRGGBBAA format
  return color:match("^#[0-9a-fA-F][6,8]$") ~= nil
end

---Validate color can be any valid WezTerm color format
---@param color any
---@return boolean is_valid
function helper.is_valid_color(color)
  if type(color) == "string" then
    -- Hex color, named color, or rgba() format
    return color:match("^#[0-9a-fA-F]+$") ~= nil
        or color:match("^rgba%(") ~= nil
        or color:match("^[a-z]+$") ~= nil
  elseif type(color) == "table" and color.Color then
    return helper.is_valid_color(color.Color)
  end
  return false
end

---Validate theme structure has all required fields
---@param theme table
---@return boolean is_valid
---@return string|nil error_message
function helper.validate_theme_structure(theme)
  local required_fields = {
    "background",
    "foreground",
    "cursor_bg",
    "cursor_fg",
    "cursor_border",
    "selection_fg",
    "selection_bg",
    "ansi",
    "brights",
    "tab_bar",
  }

  for _, field in ipairs(required_fields) do
    if theme[field] == nil then
      return false, "Missing required field: " .. field
    end
  end

  -- Validate array lengths
  if #theme.ansi ~= 8 then
    return false, "ansi array must have 8 colors, got " .. #theme.ansi
  end

  if #theme.brights ~= 8 then
    return false, "brights array must have 8 colors, got " .. #theme.brights
  end

  -- Validate tab_bar structure
  if type(theme.tab_bar) ~= "table" then
    return false, "tab_bar must be a table"
  end

  local tab_bar_required = {
    "background",
    "active_tab",
    "inactive_tab",
    "new_tab",
  }

  for _, field in ipairs(tab_bar_required) do
    if theme.tab_bar[field] == nil then
      return false, "tab_bar missing required field: " .. field
    end
  end

  return true, nil
end

---Load a colorscheme module safely
---@param module_path string
---@return table|nil module
---@return string|nil error
function helper.load_colorscheme(module_path)
  local success, module = pcall(require, module_path)
  if not success then
    return nil, "Failed to load module: " .. tostring(module)
  end

  if type(module) ~= "table" then
    return nil, "Module must return a table"
  end

  if type(module.get) ~= "function" then
    return nil, "Module must have a get() function"
  end

  if type(module.activate) ~= "function" then
    return nil, "Module must have an activate() function"
  end

  if type(module.scheme) ~= "table" then
    return nil, "Module must have a scheme table"
  end

  return module, nil
end

return helper
