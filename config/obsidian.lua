-- Obsidian Integration for WezTerm
-- Provides keybindings, URI handlers, and vault context for Obsidian workflows

local wezterm = require("wezterm")
local act = wezterm.action
local fs = require("utils.fn").fs
local str = require("utils.fn").str

local M = {}

-- Get Obsidian vault path from environment variable or use default
local function get_vault_path()
  local env_vault = os.getenv("OBSIDIAN_VAULT")
  if env_vault and env_vault ~= "" then
    return env_vault
  end
  return wezterm.home_dir .. "/github.com/obsidian"
end

-- Configuration
local config = {
  -- Main Obsidian vault path (from OBSIDIAN_VAULT env var or default)
  vault_path = get_vault_path(),

  -- Your Obsidian vault paths (keeping for backwards compatibility)
  vaults = {
    {
      name = "personal",
      path = get_vault_path(),
    },
  },

  -- Default vault for operations
  default_vault = "personal",

  -- Template directory (relative to vault root)
  template_dir = ".templates",

  -- Journal directory (relative to vault root)
  journal_dir = "journal",
}

-- Helper: Get vault by name
local function get_vault(name)
  for _, vault in ipairs(config.vaults) do
    if vault.name == name then
      return vault
    end
  end
  return nil
end

-- Helper: Get vault for current working directory
local function get_current_vault(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return nil
  end

  local cwd_path = cwd.file_path or tostring(cwd)

  for _, vault in ipairs(config.vaults) do
    if cwd_path:find(vault.path, 1, true) == 1 then
      return vault
    end
  end

  return nil
end

-- Helper: URL encode string
local function url_encode(str)
  if str then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])",
      function(c)
        return string.format("%%%02X", string.byte(c))
      end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

-- Helper: Build Obsidian URI
local function build_obsidian_uri(action, params)
  local uri = "obsidian://" .. action

  if params then
    local query_parts = {}
    for key, value in pairs(params) do
      table.insert(query_parts, key .. "=" .. url_encode(tostring(value)))
    end
    if #query_parts > 0 then
      uri = uri .. "?" .. table.concat(query_parts, "&")
    end
  end

  return uri
end

-- Action: Open vault with nvim
local function open_vault(vault_name)
  local vault = get_vault(vault_name) or get_vault(config.default_vault)
  return act.Multiple({
    act.SendString("cd " .. vault.path),
    act.SendKey({ key = "Enter" }),
    act.SendString("nvim ."),
    act.SendKey({ key = "Enter" }),
  })
end

-- Action: Open note in Obsidian
local function open_in_obsidian(window, pane)
  local vault = get_current_vault(pane)
  if not vault then
    window:toast_notification("WezTerm - Obsidian", "Not in an Obsidian vault", nil, 3000)
    return
  end

  -- Get current file if in editor
  local uri = build_obsidian_uri("open", {
    vault = vault.name,
  })

  wezterm.open_with(uri)
end

-- Action: Create new note
local function create_note(window, pane)
  local vault = get_current_vault(pane) or get_vault(config.default_vault)

  window:perform_action(
    act.PromptInputLine({
      description = "Note name:",
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= "" then
          local date = os.date("%Y-%m-%d")
          local filename = date .. "-" .. line:gsub(" ", "-"):lower() .. ".md"
          local filepath = vault.path .. "/" .. filename

          -- Create note with template
          pane:send_text(string.format(
            'nvim "+normal! Go" "%s"\n',
            filepath
          ))

          window:toast_notification("WezTerm - Obsidian", "Created: " .. filename, nil, 3000)
        end
      end),
    }),
    pane
  )
end

-- Action: Daily note
local function open_daily_note(window, pane)
  local vault = get_current_vault(pane) or get_vault(config.default_vault)
  local date = os.date("%Y-%m-%d")
  local filename = date .. ".md"
  local filepath = vault.path .. "/" .. config.journal_dir .. "/" .. filename

  -- Create journal directory if it doesn't exist
  pane:send_text(string.format(
    'mkdir -p "%s/%s" && nvim "%s"\n',
    vault.path,
    config.journal_dir,
    filepath
  ))

  window:toast_notification("WezTerm - Obsidian", "Opening daily note: " .. filename, nil, 2000)
end

-- Action: Search notes
local function search_notes(window, pane)
  local vault = get_current_vault(pane) or get_vault(config.default_vault)

  window:perform_action(
    act.PromptInputLine({
      description = "Search for:",
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= "" then
          pane:send_text(string.format(
            'cd "%s" && rg --type md --line-number "%s" | fzf --ansi --preview "glow {1}" | cut -d: -f1 | xargs nvim\n',
            vault.path,
            line
          ))
        end
      end),
    }),
    pane
  )
end

-- Action: Quick capture (from selection)
local function quick_capture(window, pane)
  local vault = get_vault(config.default_vault)
  local selection = window:get_selection_text_for_pane(pane)

  if not selection or selection == "" then
    window:toast_notification("WezTerm - Obsidian", "No text selected", nil, 2000)
    return
  end

  local inbox_file = vault.path .. "/inbox.md"
  local timestamp = os.date("%Y-%m-%d %H:%M")

  -- Append to inbox file
  local escaped_selection = selection:gsub('"', '\\"'):gsub("\n", "\\n")
  pane:send_text(string.format(
    'echo "\n\n## %s\n\n%s" >> "%s" && echo "Captured to inbox"\n',
    timestamp,
    escaped_selection,
    inbox_file
  ))

  window:toast_notification("WezTerm - Obsidian", "Captured to inbox", nil, 2000)
end

-- Action: Find note by name
local function find_note(window, pane)
  local vault = get_current_vault(pane) or get_vault(config.default_vault)

  pane:send_text(string.format(
    'cd "%s" && fd -e md -e markdown | fzf --preview "glow {}" --preview-window=right:60%% | xargs nvim\n',
    vault.path
  ))
end

-- Action: Browse vault
local function browse_vault(window, pane)
  local vault = get_current_vault(pane) or get_vault(config.default_vault)

  pane:send_text(string.format(
    'cd "%s" && yazi\n',
    vault.path
  ))
end

-- Key table for Obsidian mode
M.key_table = {
  obsidian_mode = {
    { key = "o", action = wezterm.action_callback(open_in_obsidian), desc = "Open in Obsidian" },
    { key = "n", action = wezterm.action_callback(create_note), desc = "New note" },
    { key = "d", action = wezterm.action_callback(open_daily_note), desc = "Daily note" },
    { key = "s", action = wezterm.action_callback(search_notes), desc = "Search notes" },
    { key = "f", action = wezterm.action_callback(find_note), desc = "Find note" },
    { key = "c", action = wezterm.action_callback(quick_capture), desc = "Quick capture" },
    { key = "b", action = wezterm.action_callback(browse_vault), desc = "Browse vault (Yazi)" },
    { key = "v", action = open_vault("personal"), desc = "Open vault in nvim" },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
  },
}

-- Keybindings
M.keys = {
  {
    key = "o",
    mods = "LEADER",
    action = act.ActivateKeyTable({
      name = "obsidian_mode",
      one_shot = false,
      timeout_milliseconds = 5000,
    }),
  },
}

-- Status bar indicator (callable from update-status event)
function M.get_vault_indicator(pane)
  local vault = get_current_vault(pane)
  if vault then
    return {
      text = "  " .. vault.name,
      foreground = "#7aa2f7",
      background = "#1f2335",
    }
  end
  return nil
end

-- Export helper functions for use by command palette and other modules
M.get_vault = get_vault
M.get_current_vault = get_current_vault

-- Export configuration
function M.apply_to_config(config)
  -- Add key table
  config.key_tables = config.key_tables or {}
  for name, table in pairs(M.key_table) do
    config.key_tables[name] = table
  end

  -- Add keybindings
  config.keys = config.keys or {}
  for _, key in ipairs(M.keys) do
    table.insert(config.keys, key)
  end

  return config
end

return M
