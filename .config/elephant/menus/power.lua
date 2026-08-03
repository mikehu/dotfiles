-- Power menu for walker, replacing `rofi -show p -modi p:rofi-power-menu`.
-- Elephant loads any .lua in ~/.config/elephant/menus and exposes it as the
-- provider "menus:<Name>". Bound in hyprland.lua as `walker -m menus:power`.

Name = "power"
NamePretty = "Power"

function GetEntries()
  return {
    {
      Text = "Lock",
      Icon = "system-lock-screen-symbolic",
      Actions = { activate = "loginctl lock-session" },
    },
    {
      Text = "Suspend",
      Icon = "system-suspend-symbolic",
      Actions = { activate = "systemctl suspend" },
    },
    {
      -- Verbatim from Hyprland's own 0.56 example config (/usr/share/hypr/
      -- hyprland.lua:260). hyprshutdown closes apps gracefully before exiting;
      -- the fallback is the raw dispatcher. Note the Lua form: `hyprctl
      -- dispatch exit` is the pre-0.55 syntax and now fails to parse, silently
      -- when run from a menu action where stderr goes nowhere.
      Text = "Log out",
      Icon = "system-log-out-symbolic",
      Actions = {
        activate = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'",
      },
    },
    {
      Text = "Reboot",
      Icon = "system-reboot-symbolic",
      Actions = { activate = "systemctl reboot" },
    },
    {
      Text = "Shut down",
      Icon = "system-shutdown-symbolic",
      Actions = { activate = "systemctl poweroff" },
    },
  }
end
