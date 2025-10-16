---@module "spec.colorschemes.theme_validator_spec"
---Generic theme validation tests that can be applied to any colorscheme

local helper = require("spec.spec_helper")

describe("Theme validator", function()
  setup(function()
    package.loaded.wezterm = helper.mock_wezterm()
  end)

  describe("helper.validate_theme_structure", function()
    it("should accept a valid theme", function()
      local valid_theme = {
        background = "#000000",
        foreground = "#ffffff",
        cursor_bg = "#ffffff",
        cursor_fg = "#000000",
        cursor_border = "#ffffff",
        selection_fg = "#ffffff",
        selection_bg = "#333333",
        ansi = {"#000", "#f00", "#0f0", "#ff0", "#00f", "#f0f", "#0ff", "#fff"},
        brights = {"#666", "#f66", "#6f6", "#ff6", "#66f", "#f6f", "#6ff", "#fff"},
        tab_bar = {
          background = "#000000",
          active_tab = {bg_color = "#ffffff", fg_color = "#000000"},
          inactive_tab = {bg_color = "#333333", fg_color = "#ffffff"},
          new_tab = {bg_color = "#333333", fg_color = "#ffffff"},
        },
      }

      local valid, err = helper.validate_theme_structure(valid_theme)
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("should reject theme missing background", function()
      local invalid_theme = {
        foreground = "#ffffff",
        cursor_bg = "#ffffff",
        cursor_fg = "#000000",
        cursor_border = "#ffffff",
        selection_fg = "#ffffff",
        selection_bg = "#333333",
        ansi = {"#000", "#f00", "#0f0", "#ff0", "#00f", "#f0f", "#0ff", "#fff"},
        brights = {"#666", "#f66", "#6f6", "#ff6", "#66f", "#f6f", "#6ff", "#fff"},
        tab_bar = {
          background = "#000000",
          active_tab = {bg_color = "#ffffff", fg_color = "#000000"},
          inactive_tab = {bg_color = "#333333", fg_color = "#ffffff"},
          new_tab = {bg_color = "#333333", fg_color = "#ffffff"},
        },
      }

      local valid, err = helper.validate_theme_structure(invalid_theme)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("background", err)
    end)

    it("should reject theme with wrong number of ANSI colors", function()
      local invalid_theme = {
        background = "#000000",
        foreground = "#ffffff",
        cursor_bg = "#ffffff",
        cursor_fg = "#000000",
        cursor_border = "#ffffff",
        selection_fg = "#ffffff",
        selection_bg = "#333333",
        ansi = {"#000", "#f00", "#0f0"}, -- Only 3 colors
        brights = {"#666", "#f66", "#6f6", "#ff6", "#66f", "#f6f", "#6ff", "#fff"},
        tab_bar = {
          background = "#000000",
          active_tab = {bg_color = "#ffffff", fg_color = "#000000"},
          inactive_tab = {bg_color = "#333333", fg_color = "#ffffff"},
          new_tab = {bg_color = "#333333", fg_color = "#ffffff"},
        },
      }

      local valid, err = helper.validate_theme_structure(invalid_theme)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("ansi", err)
      assert.matches("8 colors", err)
    end)

    it("should reject theme with missing tab_bar.active_tab", function()
      local invalid_theme = {
        background = "#000000",
        foreground = "#ffffff",
        cursor_bg = "#ffffff",
        cursor_fg = "#000000",
        cursor_border = "#ffffff",
        selection_fg = "#ffffff",
        selection_bg = "#333333",
        ansi = {"#000", "#f00", "#0f0", "#ff0", "#00f", "#f0f", "#0ff", "#fff"},
        brights = {"#666", "#f66", "#6f6", "#ff6", "#66f", "#f6f", "#6ff", "#fff"},
        tab_bar = {
          background = "#000000",
          -- Missing active_tab
          inactive_tab = {bg_color = "#333333", fg_color = "#ffffff"},
          new_tab = {bg_color = "#333333", fg_color = "#ffffff"},
        },
      }

      local valid, err = helper.validate_theme_structure(invalid_theme)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("active_tab", err)
    end)
  end)

  describe("helper.is_valid_color", function()
    it("should accept valid hex colors", function()
      assert.is_true(helper.is_valid_color("#000000"))
      assert.is_true(helper.is_valid_color("#ffffff"))
      assert.is_true(helper.is_valid_color("#a8df5a"))
      assert.is_true(helper.is_valid_color("#ABC"))
    end)

    it("should accept rgba format", function()
      assert.is_true(helper.is_valid_color("rgba(255, 0, 0, 0.5)"))
      assert.is_true(helper.is_valid_color("rgba(0,0,0,1)"))
    end)

    it("should accept named colors", function()
      assert.is_true(helper.is_valid_color("red"))
      assert.is_true(helper.is_valid_color("blue"))
      assert.is_true(helper.is_valid_color("transparent"))
    end)

    it("should accept Color table format", function()
      assert.is_true(helper.is_valid_color({Color = "#ff0000"}))
      assert.is_true(helper.is_valid_color({Color = "rgba(0,0,0,0.5)"}))
    end)

    it("should reject invalid formats", function()
      assert.is_false(helper.is_valid_color(123))
      assert.is_false(helper.is_valid_color(true))
      assert.is_false(helper.is_valid_color(nil))
      assert.is_false(helper.is_valid_color({}))
    end)
  end)

  describe("helper.load_colorscheme", function()
    it("should load a valid colorscheme module", function()
      local module, err = helper.load_colorscheme("picker.assets.colorschemes.dracula")
      assert.is_nil(err)
      assert.is_table(module)
      assert.is_function(module.get)
      assert.is_function(module.activate)
      assert.is_table(module.scheme)
    end)

    it("should fail gracefully for non-existent module", function()
      local module, err = helper.load_colorscheme("picker.assets.colorschemes.nonexistent")
      assert.is_nil(module)
      assert.is_string(err)
      assert.matches("Failed to load", err)
    end)
  end)
end)
