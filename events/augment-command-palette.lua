---@module "events.augment-command-palette"
---@author sravioli
---@license GNU-GPLv3

---@diagnostic disable: undefined-field
local wt = require "wezterm"
local act = wt.action

wt.on("augment-command-palette", function(window, pane)
  wt.log_info("augment-command-palette event fired")

  -- Base commands
  local commands = {
    {
      brief = "Rename tab",
      icon = "md_rename_box",
      action = act.PromptInputLine {
        description = "Enter new name for tab",
        action = wt.action_callback(function(inner_window, _, line)
          if line then
            inner_window:active_tab():set_title(line)
          end
        end),
      },
    },
    {
      brief = "Colorscheme picker",
      icon = "md_palette",
      action = require("picker.colorscheme"):pick(),
    },
    {
      brief = "Font picker",
      icon = "md_format_font",
      action = require("picker.font"):pick(),
    },
    {
      brief = "Font size picker",
      icon = "md_format_font_size_decrease",
      action = require("picker.font-size"):pick(),
    },
    {
      brief = "Font leading picker",
      icon = "fa_text_height",
      action = require("picker.font-leading"):pick(),
    },
  }

  -- Try to load Obsidian module
  wt.log_info("Attempting to load obsidian module...")
  local status, obsidian = pcall(require, "config.obsidian")

  if not status then
    wt.log_error("Failed to load obsidian module: " .. tostring(obsidian))
    -- Add error command to palette
    table.insert(commands, {
      brief = "❌ Obsidian: Module Load Error",
      icon = "md_alert",
      action = act.Nop,
    })
    return commands
  end

  wt.log_info("Obsidian module loaded successfully")

  -- Check if functions exist
  if type(obsidian.get_vault) ~= "function" then
    wt.log_error("obsidian.get_vault is not a function, type: " .. type(obsidian.get_vault))
    table.insert(commands, {
      brief = "❌ Obsidian: get_vault missing",
      icon = "md_alert",
      action = act.Nop,
    })
    return commands
  end

  if type(obsidian.get_current_vault) ~= "function" then
    wt.log_error("obsidian.get_current_vault is not a function")
    table.insert(commands, {
      brief = "❌ Obsidian: get_current_vault missing",
      icon = "md_alert",
      action = act.Nop,
    })
    return commands
  end

  wt.log_info("All obsidian functions found")

  -- Try to get vault context
  local vault_context_status, vault_context = pcall(obsidian.get_vault_indicator, pane)
  if not vault_context_status then
    wt.log_error("Error getting vault context: " .. tostring(vault_context))
    vault_context = nil
  end

  -- Add Obsidian commands section
  table.insert(commands, {
    brief = "─── Obsidian ───",
    icon = "md_notebook",
    action = act.Nop,
  })

  table.insert(commands, {
    brief = "Obsidian: New Note",
    icon = "md_file_plus",
    action = act.PromptInputLine {
      description = "Note name:",
      action = wt.action_callback(function(inner_window, inner_pane, line)
        if line and line ~= "" then
          local vault_status, vault = pcall(obsidian.get_current_vault, inner_pane)
          if not vault_status or not vault then
            vault_status, vault = pcall(obsidian.get_vault, "personal")
          end

          if vault_status and vault then
            local date = os.date("%Y-%m-%d")
            local filename = date .. "-" .. line:gsub(" ", "-"):lower() .. ".md"
            local filepath = vault.path .. "/" .. filename
            inner_pane:send_text(string.format('nvim "+normal! Go" "%s"\n', filepath))
            inner_window:toast_notification("Obsidian", "Created: " .. filename, nil, 3000)
          else
            inner_window:toast_notification("Obsidian", "Error: Could not find vault", nil, 3000)
            wt.log_error("Could not get vault: " .. tostring(vault))
          end
        end
      end),
    },
  })

  table.insert(commands, {
    brief = "Obsidian: Daily Note",
    icon = "md_calendar_today",
    action = wt.action_callback(function(inner_window, inner_pane)
      local vault_status, vault = pcall(obsidian.get_current_vault, inner_pane)
      if not vault_status or not vault then
        vault_status, vault = pcall(obsidian.get_vault, "personal")
      end

      if vault_status and vault then
        local date = os.date("%Y-%m-%d")
        local filename = date .. ".md"
        local filepath = vault.path .. "/journal/" .. filename
        inner_pane:send_text(string.format(
          'mkdir -p "%s/journal" && nvim "%s"\n',
          vault.path,
          filepath
        ))
        inner_window:toast_notification("Obsidian", "Opening: " .. filename, nil, 2000)
      else
        inner_window:toast_notification("Obsidian", "Error: Could not find vault", nil, 3000)
        wt.log_error("Could not get vault")
      end
    end),
  })

  -- Add vault context indicator if in vault
  if vault_context then
    table.insert(commands, {
      brief = "✓ Current Vault: " .. vault_context.text,
      icon = "md_check_circle",
      action = act.Nop,
    })
  else
    wt.log_info("No vault context (not in a vault directory)")
  end

  -- Add Claude commands section
  table.insert(commands, {
    brief = "─── Claude Code ───",
    icon = "md_robot",
    action = act.Nop,
  })

  table.insert(commands, {
    brief = "Claude: Run in Current Dir",
    icon = "md_robot",
    action = wt.action_callback(function(inner_window, inner_pane)
      inner_pane:send_text("claude\n")
      inner_window:toast_notification("Claude", "Starting Claude Code...", nil, 2000)
    end),
  })

  table.insert(commands, {
    brief = "Claude: Initialize Project",
    icon = "md_folder_plus",
    action = wt.action_callback(function(inner_window, inner_pane)
      inner_pane:send_text("claude /init\n")
      inner_window:toast_notification("Claude", "Initializing project...", nil, 2000)
    end),
  })

  table.insert(commands, {
    brief = "Claude: Prompt",
    icon = "md_message_text",
    action = act.PromptInputLine {
      description = "Claude prompt:",
      action = wt.action_callback(function(inner_window, inner_pane, line)
        if line and line ~= "" then
          inner_pane:send_text(string.format('claude "%s"\n', line:gsub('"', '\\"')))
          inner_window:toast_notification("Claude", "Running prompt...", nil, 2000)
        end
      end),
    },
  })

  table.insert(commands, {
    brief = "Claude: Create Commit",
    icon = "md_source_commit",
    action = wt.action_callback(function(inner_window, inner_pane)
      inner_pane:send_text("claude /commit\n")
      inner_window:toast_notification("Claude", "Creating commit...", nil, 2000)
    end),
  })

  table.insert(commands, {
    brief = "Claude: Create PR",
    icon = "md_source_pull",
    action = wt.action_callback(function(inner_window, inner_pane)
      inner_pane:send_text("claude /pr\n")
      inner_window:toast_notification("Claude", "Creating pull request...", nil, 2000)
    end),
  })

  table.insert(commands, {
    brief = "Claude: Help",
    icon = "md_help_circle",
    action = wt.action_callback(function(inner_window, inner_pane)
      inner_pane:send_text("claude /help\n")
    end),
  })

  table.insert(commands, {
    brief = "Claude: Clear Session",
    icon = "md_broom",
    action = wt.action_callback(function(inner_window, inner_pane)
      inner_pane:send_text("claude /clear\n")
      inner_window:toast_notification("Claude", "Session cleared", nil, 2000)
    end),
  })

  wt.log_info("Returning " .. #commands .. " commands")

  return commands
end)
