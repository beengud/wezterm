---@module "spec.colorschemes.slime_spec"
---Tests for the Slime colorscheme

local helper = require("spec.spec_helper")

describe("Slime colorscheme", function()
  local slime

  setup(function()
    -- Mock wezterm module
    package.loaded.wezterm = helper.mock_wezterm()
  end)

  before_each(function()
    -- Reload the module fresh for each test
    package.loaded["picker.assets.colorschemes.slime"] = nil
    local module, err = helper.load_colorscheme("picker.assets.colorschemes.slime")
    assert.is_nil(err, "Failed to load slime colorscheme: " .. tostring(err))
    slime = module
  end)

  describe("module interface", function()
    it("should have a get() function", function()
      assert.is_function(slime.get)
    end)

    it("should have an activate() function", function()
      assert.is_function(slime.activate)
    end)

    it("should have a scheme table", function()
      assert.is_table(slime.scheme)
    end)

    it("get() should return id and label", function()
      local result = slime.get()
      assert.is_table(result)
      assert.is_string(result.id)
      assert.is_string(result.label)
      assert.equals("slime", result.id)
    end)
  end)

  describe("theme structure", function()
    it("should have all required color fields", function()
      local theme = slime.scheme
      assert.is_not_nil(theme.background)
      assert.is_not_nil(theme.foreground)
      assert.is_not_nil(theme.cursor_bg)
      assert.is_not_nil(theme.cursor_fg)
      assert.is_not_nil(theme.cursor_border)
      assert.is_not_nil(theme.selection_fg)
      assert.is_not_nil(theme.selection_bg)
    end)

    it("should pass full theme structure validation", function()
      local valid, err = helper.validate_theme_structure(slime.scheme)
      assert.is_true(valid, err)
    end)
  end)

  describe("ANSI colors", function()
    it("should have exactly 8 ANSI colors", function()
      assert.equals(8, #slime.scheme.ansi)
    end)

    it("should have valid color formats for ANSI colors", function()
      for i, color in ipairs(slime.scheme.ansi) do
        assert.is_true(
          helper.is_valid_color(color),
          string.format("ansi[%d] has invalid color format: %s", i, tostring(color))
        )
      end
    end)

    it("should have Slime-specific ANSI colors", function()
      -- Verify key Slime theme colors
      assert.equals("#cd6564", slime.scheme.ansi[2]) -- Red
      assert.equals("#AEC199", slime.scheme.ansi[3]) -- Green
      assert.equals("#fff099", slime.scheme.ansi[4]) -- Yellow
      assert.equals("#6D9CBE", slime.scheme.ansi[5]) -- Blue
      assert.equals("#B081B9", slime.scheme.ansi[6]) -- Magenta
      assert.equals("#80B5B3", slime.scheme.ansi[7]) -- Cyan
    end)
  end)

  describe("bright colors", function()
    it("should have exactly 8 bright colors", function()
      assert.equals(8, #slime.scheme.brights)
    end)

    it("should have valid color formats for bright colors", function()
      for i, color in ipairs(slime.scheme.brights) do
        assert.is_true(
          helper.is_valid_color(color),
          string.format("brights[%d] has invalid color format: %s", i, tostring(color))
        )
      end
    end)
  end)

  describe("main colors", function()
    it("should have Slime background color", function()
      assert.equals("#1e2324", slime.scheme.background)
    end)

    it("should have Slime foreground color", function()
      assert.equals("#e0e0e0", slime.scheme.foreground)
    end)

    it("should have Slime cursor color (bright green)", function()
      assert.equals("#a8df5a", slime.scheme.cursor_bg)
    end)

    it("should have valid selection colors", function()
      assert.is_true(helper.is_valid_color(slime.scheme.selection_bg))
      assert.is_true(helper.is_valid_color(slime.scheme.selection_fg))
    end)
  end)

  describe("tab bar", function()
    it("should have tab_bar configuration", function()
      assert.is_table(slime.scheme.tab_bar)
    end)

    it("should have required tab_bar fields", function()
      local tab_bar = slime.scheme.tab_bar
      assert.is_not_nil(tab_bar.background)
      assert.is_table(tab_bar.active_tab)
      assert.is_table(tab_bar.inactive_tab)
      assert.is_table(tab_bar.new_tab)
    end)

    it("active_tab should have bg_color and fg_color", function()
      assert.is_not_nil(slime.scheme.tab_bar.active_tab.bg_color)
      assert.is_not_nil(slime.scheme.tab_bar.active_tab.fg_color)
    end)
  end)

  describe("activation", function()
    it("should activate without errors", function()
      local Config = {}
      local opts = { id = "slime", label = "Slime" }

      assert.has_no.errors(function()
        slime.activate(Config, opts)
      end)
    end)

    it("should set color_scheme in Config", function()
      local Config = {}
      local opts = { id = "slime", label = "Slime" }

      slime.activate(Config, opts)

      assert.equals("slime", Config.color_scheme)
    end)
  end)
end)
