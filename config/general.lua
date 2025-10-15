local Icons = require "utils.class.icon"
local fs = require("utils.fn").fs

local Config = {}

if fs.platform().is_win then
  Config.default_prog =
    { "pwsh", "-NoLogo", "-ExecutionPolicy", "RemoteSigned", "-NoProfileLoadTime" }

  Config.launch_menu = {
    {
      label = Icons.Progs["pwsh.exe"] .. " PowerShell V7",
      args = {
        "pwsh",
        "-NoLogo",
        "-ExecutionPolicy",
        "RemoteSigned",
        "-NoProfileLoadTime",
      },
      cwd = "~",
    },
    {
      label = Icons.Progs["pwsh.exe"] .. " PowerShell V5",
      args = { "powershell" },
      cwd = "~",
    },
    { label = "Command Prompt", args = { "cmd.exe" }, cwd = "~" },
    { label = Icons.Progs["git"] .. " Git bash", args = { "sh", "-l" }, cwd = "~" },
  }

  -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
  Config.wsl_domains = {
    {
      name = "WSL:Ubuntu",
      distribution = "Ubuntu",
      username = "sravioli",
      default_cwd = "~",
      default_prog = { "bash", "-i", "-l" },
    },
    {
      name = "WSL:Alpine",
      distribution = "Alpine",
      username = "sravioli",
      default_cwd = "/home/sravioli",
    },
  }
end

Config.default_cwd = fs.home()

-- Window positioning - bottom third of screen
-- Get screen dimensions and position window at bottom third
local wt = require("wezterm")
wt.on("gui-startup", function(cmd)
  local tab, pane, window = wt.mux.spawn_window(cmd or {})

  -- Get screen dimensions
  local screen = wt.gui.screens().active
  local width = screen.width
  local height = screen.height

  -- Bottom third positioning
  local window_height = math.floor(height / 3)
  local window_y = height - window_height

  -- Set window position and size
  window:gui_window():set_position(0, window_y)
  window:gui_window():set_inner_size(width, window_height)
end)

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config
