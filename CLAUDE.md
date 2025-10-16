# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular WezTerm terminal emulator configuration written in Lua. The configuration uses a class-based architecture with a custom config builder pattern, event-driven status bar rendering, and interactive pickers for runtime customization.

## Architecture

### Core Entry Point

- `wezterm.lua` - Main entry point that initializes the Config class and loads modules
- Uses `Config:new():add("config"):add("mappings")` pattern to merge configurations

### Config System (`utils/class/config.lua`)

The config system uses a builder pattern:
- `Config:new()` - Creates a WezTerm config object (uses strict mode if available)
- `Config:add(spec)` - Merges module configurations by requiring and merging tables
- Automatically detects and warns about duplicate keys

### Module Structure

Configuration is split across modular files that return config tables:

**config/** - Core configuration modules
- `init.lua` - Merges appearance, font, tab-bar, general, gpu configs
- `appearance.lua` - Color schemes, cursor, visual bell, window padding
- `font.lua` - Font configuration with FiraCode and Monaspace variants
- `tab-bar.lua` - Tab bar appearance settings
- `general.lua` - General WezTerm settings
- `gpu.lua` - GPU/rendering settings

**mappings/** - Keybinding configuration
- `init.lua` - Merges default and mode keybindings
- `default.lua` - Standard keybindings (`<C-S-*>` patterns for common actions)
- `modes.lua` - Modal keybindings (search, window, copy, font, help, pick modes)

**events/** - Event handlers (auto-loaded in `wezterm.lua`)
- `update-status.lua` - Complex status bar with dynamic width calculation
- `format-tab-title.lua` - Tab title formatting
- `new-tab-button-click.lua` - New tab button behavior
- `augment-command-palette.lua` - Command palette enhancements

**picker/** - Interactive runtime configuration
- `colorscheme.lua`, `font.lua`, `font-size.lua`, `font-leading.lua` - Runtime pickers
- `assets/` - Contains available choices (colorschemes, fonts, sizes, leadings)
- Uses `utils/class/picker.lua` for the picker framework

**utils/** - Utility functions and classes
- `fn.lua` - Function utilities (fs, string, table, math, color, key helpers)
- `class/` - Object-oriented classes (Config, Picker, Icon, Layout, Logger)
- `external/` - Third-party utilities (inspect.lua for debugging)

## Key Design Patterns

### 1. Config Builder Pattern
```lua
local Config = require("utils.class.config"):new()
return Config:add("config"):add("mappings")
```

### 2. Event-Driven Status Bar
The `update-status` event uses complex width calculations to dynamically fit elements:
- Computes usable width based on window/pane dimensions
- Uses cartesian product combinations to find best-fit status bar elements
- Adapts display based on available space (full, truncated, icon-only)

### 3. Picker System
Interactive runtime configuration using `wt.action.InputSelector`:
- Auto-discovers choices from `picker/assets/` subdirectories
- Each picker asset returns `{ get = function, activate = function }`
- `get()` returns choices, `activate()` applies the selection to config overrides

### 4. Modal Keybinding Modes
Six modal modes with context-specific keybindings:
- `search_mode`, `window_mode`, `copy_mode`, `font_mode`, `help_mode`, `pick_mode`
- Modes display contextual prompts in the status bar when active
- Leader key is `<C-Space>` with 1000ms timeout

## Testing and Validation

There is no automated test suite. Manual testing workflow:
1. Make changes to `.lua` files
2. Reload config with `<C-S-r>` (or restart WezTerm)
3. Use `<C-S-l>` to show debug overlay if issues occur
4. Check console output for Logger warnings/errors

## Keybinding Conventions

- `<C-S-*>` - Core actions (copy, paste, new tab, etc.)
- `<C-Tab>` / `<C-S-Tab>` - Tab navigation
- `<M-CR>` - Toggle fullscreen
- Leader (`<C-Space>`) - Enter modal modes
- Modal mode keys - Single letter commands (depends on mode)

## Color Scheme System

Color schemes are loaded dynamically:
- Stored in `picker/assets/colorschemes/` as Lua modules
- Each module returns a `scheme` table with ANSI/bright colors
- `utils.fn.color.get_schemes()` discovers and loads all schemes
- Runtime switching via picker or config overrides

## Font Configuration

Multi-font setup with feature flags:
- Primary: FiraCode Nerd Font with ligature features (`cv*`, `ss*` features)
- Italic: Monaspace Radon Var
- Bold+Italic: Monaspace Krypton Var (scaled 1.1x)
- Fallbacks: Noto Color Emoji, LegacyComputing, Symbols Nerd Font

Font size is platform-dependent:
- Windows: 9.5
- macOS/Linux: 10.5

## Status Bar Width Calculation

The status bar uses sophisticated width management:
1. Calculate usable width from window/pane pixel dimensions
2. Account for tabs, mode indicator, workspace, new tab button
3. Generate combination sets (battery, time, cwd, hostname variants)
4. Find best-fit combination using cartesian product evaluation
5. Render right-to-left with color gradients

## Working with This Codebase

### Adding a New Color Scheme
1. Create `picker/assets/colorschemes/your-scheme.lua`
2. Export `{ get = function, activate = function }`
3. `get()` returns `{ id = "scheme-name", label = "Display Name" }`
4. Define `scheme` table with `background`, `foreground`, `ansi`, `brights`
5. Picker auto-discovers on next reload

### Adding a New Font
1. Create `picker/assets/fonts/your-font.lua`
2. Follow same picker pattern as colorschemes
3. Return font configuration table in `activate()`
4. Update `Config.font` or `Config.font_rules` in overrides

### Modifying Status Bar Elements
Edit `events/update-status.lua`:
- `e.__get_modes()` - Mode definitions and colors
- `e.set_left_status()` - Left side rendering (mode, workspace)
- `e.set_right_status()` - Right side rendering (battery, time, cwd, hostname)
- Combinations defined at lines 290-296

### Adding Keybindings
- Default keys: Edit `mappings/default.lua`
- Modal keys: Edit `mappings/modes.lua`
- Format: `{ "key-combo", action, "description" }`
- Use `utils.fn.key` helpers for parsing key strings

## Common Utilities

**String utilities** (`utils.fn.str`):
- `width()` - Calculate display width accounting for wide chars
- `pad()` / `padl()` / `padr()` - Padding functions
- `format_tab_title()` - Tab title formatting

**File system** (`utils.fn.fs`):
- `ls_dir()` - List directory contents
- `pathconcat()` - Join paths with correct separator
- `pathshortener()` - Shorten paths intelligently
- `get_cwd_hostname()` - Extract working directory and hostname

**Color utilities** (`utils.fn.color`):
- `get_schemes()` - Load all color schemes
- `get_scheme()` - Get current/default scheme
- `set_tab_button()` - Configure tab bar button colors

**Layout class** (`utils.class.layout`):
- `append(fg, bg, text, attributes)` - Add formatted text
- `format()` - Generate WezTerm format string

## Debugging

The codebase includes a Logger class (`utils/class/logger.lua`):
- `log:debug()`, `log:info()`, `log:warn()`, `log:error()`
- Logs include module context (e.g., "Picker > Colorscheme")
- Use `require("utils.external.inspect")` for deep object inspection

## Platform Differences

Platform detection via `utils.fn.fs.platform()`:
- `is_win`, `is_mac`, `is_linux` - Boolean flags
- Affects font sizes, path separators, default behaviors

## Important Notes

- All configuration is runtime-modifiable via `window:set_config_overrides()`
- Events are registered globally with `wt.on(event_name, handler)`
- The config uses strict mode to catch typos in config keys
- Status bar recalculates on every `update-status` event (performance-sensitive)
- Picker choices are lazily loaded only when picker is invoked
