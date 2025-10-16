---@module "spec.colorschemes.all_themes_spec"
---Regression tests for all existing colorschemes

local helper = require("spec.spec_helper")

-- List all existing colorscheme modules
local colorschemes = {
  "bamboo",
  "bamboo-light",
  "bamboo-multiplex",
  "carbonfox",
  "catppuccin-frappe",
  "catppuccin-latte",
  "catppuccin-macchiato",
  "catppuccin-mocha",
  "dawnfox",
  "dayfox",
  "dracula",
  "duskfox",
  "eldritch",
  "hardhacker",
  "kanagawa-dragon",
  "kanagawa-lotus",
  "kanagawa-wave",
  "nightfox",
  "nordfox",
  "poimandres",
  "poimandres-storm",
  "rose-pine",
  "rose-pine-dawn",
  "rose-pine-moon",
  "slime",
  "terafox",
  "tokyonight-day",
  "tokyonight-moon",
  "tokyonight-night",
  "tokyonight-storm",
}

describe("All colorschemes regression tests", function()
  setup(function()
    package.loaded.wezterm = helper.mock_wezterm()
  end)

  for _, scheme_name in ipairs(colorschemes) do
    describe(scheme_name .. " colorscheme", function()
      local module

      before_each(function()
        package.loaded["picker.assets.colorschemes." .. scheme_name] = nil
        local loaded_module, err = helper.load_colorscheme("picker.assets.colorschemes." .. scheme_name)
        assert.is_nil(err, "Failed to load " .. scheme_name .. ": " .. tostring(err))
        module = loaded_module
      end)

      it("should have valid module interface", function()
        assert.is_function(module.get)
        assert.is_function(module.activate)
        assert.is_table(module.scheme)
      end)

      it("get() should return valid result", function()
        local result = module.get()
        assert.is_table(result)
        assert.is_string(result.id)
        assert.is_string(result.label)
      end)

      it("should have valid theme structure", function()
        local valid, err = helper.validate_theme_structure(module.scheme)
        assert.is_true(valid, err)
      end)

      it("should have valid ANSI colors", function()
        for i, color in ipairs(module.scheme.ansi) do
          assert.is_true(
            helper.is_valid_color(color),
            string.format("%s: ansi[%d] invalid: %s", scheme_name, i, tostring(color))
          )
        end
      end)

      it("should have valid bright colors", function()
        for i, color in ipairs(module.scheme.brights) do
          assert.is_true(
            helper.is_valid_color(color),
            string.format("%s: brights[%d] invalid: %s", scheme_name, i, tostring(color))
          )
        end
      end)

      it("should activate without errors", function()
        local Config = {}
        local opts = { id = scheme_name, label = scheme_name }

        assert.has_no.errors(function()
          module.activate(Config, opts)
        end)
      end)
    end)
  end

  it("should have tests for all colorschemes in picker directory", function()
    -- This test ensures we don't forget to add new colorschemes to the list
    local lfs = require("lfs")
    local colorschemes_dir = helper.mock_wezterm().config_dir .. "/picker/assets/colorschemes"
    local found_schemes = {}

    for file in lfs.dir(colorschemes_dir) do
      if file:match("%.lua$") and file ~= "init.lua" then
        local scheme_name = file:gsub("%.lua$", "")
        found_schemes[scheme_name] = true
      end
    end

    -- Check that all found schemes are in our test list
    for scheme_name in pairs(found_schemes) do
      local found_in_list = false
      for _, test_scheme in ipairs(colorschemes) do
        if test_scheme == scheme_name then
          found_in_list = true
          break
        end
      end

      assert.is_true(
        found_in_list,
        string.format(
          "Colorscheme '%s' found in directory but not in test list. Please add it to spec/colorschemes/all_themes_spec.lua",
          scheme_name
        )
      )
    end
  end)
end)
