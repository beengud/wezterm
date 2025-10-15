local Config = require("utils.class.config"):new()

require "events.update-status"
require "events.format-tab-title"
require "events.new-tab-button-click"
require "events.augment-command-palette"

local obsidian = require("config.obsidian")
local claude = require("config.claude")

-- Chain config additions and return the final config table
return Config:add("config"):add("mappings"):add(obsidian):add(claude).config
