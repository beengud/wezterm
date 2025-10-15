-- Claude Code Integration for WezTerm
-- Provides keybindings and commands for Claude Code workflows

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Action: Run claude in current directory
local function run_claude(window, pane)
  pane:send_text("claude\n")
  window:toast_notification("WezTerm - Claude", "Starting Claude Code...", nil, 2000)
end

-- Action: Initialize Claude in current directory
local function claude_init(window, pane)
  pane:send_text("claude /init\n")
  window:toast_notification("WezTerm - Claude", "Initializing Claude Code project...", nil, 2000)
end

-- Action: Run claude with specific prompt
local function claude_prompt(window, pane)
  window:perform_action(
    act.PromptInputLine({
      description = "Claude prompt:",
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= "" then
          pane:send_text(string.format('claude "%s"\n', line:gsub('"', '\\"')))
          window:toast_notification("WezTerm - Claude", "Running Claude...", nil, 2000)
        end
      end),
    }),
    pane
  )
end

-- Action: Run claude /help
local function claude_help(window, pane)
  pane:send_text("claude /help\n")
end

-- Action: Run claude /clear
local function claude_clear(window, pane)
  pane:send_text("claude /clear\n")
  window:toast_notification("WezTerm - Claude", "Cleared Claude session", nil, 2000)
end

-- Action: Run claude /commit
local function claude_commit(window, pane)
  pane:send_text("claude /commit\n")
  window:toast_notification("WezTerm - Claude", "Creating git commit...", nil, 2000)
end

-- Action: Run claude /pr
local function claude_pr(window, pane)
  pane:send_text("claude /pr\n")
  window:toast_notification("WezTerm - Claude", "Creating pull request...", nil, 2000)
end

-- Action: Quick fix with Claude
local function claude_fix(window, pane)
  local selection = window:get_selection_text_for_pane(pane)

  if selection and selection ~= "" then
    -- If there's a selection, use it as context for fixing
    pane:send_text(string.format('claude "Fix this: %s"\n', selection:gsub('"', '\\"')))
  else
    -- Otherwise, just ask Claude to fix issues
    pane:send_text('claude "Fix any issues in the current file"\n')
  end

  window:toast_notification("WezTerm - Claude", "Running fix...", nil, 2000)
end

-- Key table for Claude mode
M.key_table = {
  claude_mode = {
    { key = "c", action = wezterm.action_callback(run_claude), desc = "Run Claude" },
    { key = "i", action = wezterm.action_callback(claude_init), desc = "Initialize project" },
    { key = "p", action = wezterm.action_callback(claude_prompt), desc = "Prompt Claude" },
    { key = "h", action = wezterm.action_callback(claude_help), desc = "Show help" },
    { key = "x", action = wezterm.action_callback(claude_clear), desc = "Clear session" },
    { key = "m", action = wezterm.action_callback(claude_commit), desc = "Create commit" },
    { key = "r", action = wezterm.action_callback(claude_pr), desc = "Create PR" },
    { key = "f", action = wezterm.action_callback(claude_fix), desc = "Quick fix" },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
  },
}

-- Keybindings
M.keys = {
  {
    key = "c",
    mods = "LEADER",
    action = act.ActivateKeyTable({
      name = "claude_mode",
      one_shot = false,
      timeout_milliseconds = 5000,
    }),
  },
}

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
