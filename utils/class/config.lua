---@module "utils.class.config"
---@author sravioli
---@license GNU-GPLv3

---locals are faster
-- local type, pcall, pairs, setmetatable = type, pcall, pairs, setmetatable

local wt = require "wezterm"

---@class Utils.Class.Config
local M = {}

---@package
---
---Class logger
M.log = require("utils.class.logger"):new "Config"

---Initializes a new Config object.
---Creates a new Wezterm configuration object.  If `wezterm.config_builder()` is available,
---it will use the config builder and set the configuration to strict mode.
---
---@return Utils.Class.Config self new instance of the Wezterm configuration.
function M:new()
  local config = {}

  if wt.config_builder then ---@diagnostic disable-line: undefined-field
    config = wt.config_builder() ---@diagnostic disable-line: undefined-field
    config:set_strict_mode(true)
    M.log:debug "Wezterm's config builder is available"
  else
    M.log:warn "Wezterm's config builder is unavailable"
  end

  -- Create proper instance with config as property, not as self
  local instance = setmetatable({ config = config }, { __index = M })
  return instance
end

---Adds a module to the Wezterm configuration.
---This function allows you to extend the Wezterm configuration by adding new options
---from a specified module.  If a string is provided, it requires the module and merges
---its options.  If a table is provided, it merges the table directly into the configuration.
---
---**Example usage**
---
---~~~lua
---local Config = require "config"
---return Config:new():add(require "<module.name>")
---~~~
---
---@param spec string|table lua `require()` path to config table or config table
---@return Utils.Class.Config # Modified Config object with the new options.
function M:add(spec)
  if type(spec) == "string" then
    if not (pcall(require, spec)) then
      M.log:error("Unable to require module %s", spec)
      return self
    end
    spec = require(spec)
  end

  -- Check if module has apply_to_config method (for complex modules)
  if type(spec.apply_to_config) == "function" then
    M.log:debug("Calling apply_to_config() for module")
    spec.apply_to_config(self.config)
    return self  -- Return Config object for chaining
  end

  -- Otherwise, merge directly into config
  for key, value in pairs(spec) do
    if self.config[key] == spec[key] then
      M.log:warn("found duplicate! old: %s, new: %s", self.config[key], spec[key])
    end
    self.config[key] = value
  end

  return self  -- ✓ Return Config object, not self.config
end

return M
