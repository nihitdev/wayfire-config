# ARCHNEMESIS · Wayfire

Wayfire 0.11 configuration with the same daily applications and controls as the other ARCHNEMESIS sessions, using Wayfire's own floating-first window model and effects.

## Files

- `wayfire.ini` — canonical Wayfire config; Wayfire does not provide config includes.
- `waybar.jsonc`, `waybar.css` — Wayfire-specific bar. The taskbar is provided by the foreign-toplevel protocol; use Expo for the workspace overview.
- `scripts/` — session startup, wallpaper, lock, and power helpers.
- `hyprlock.conf` — generated at lock time from the existing Hyprlock template; it is not a shared config.
- `current-wallpaper` — created by the Wayfire wallpaper picker.

## Controls

| Keys | Action |
| --- | --- |
| Super+Return / B / E / Space / G / N | Kitty / Helium / Dolphin / Rofi / Kdenlive / Kitty + Neovim |
| Super+W | Close focused window |
| Super+H/J/K and Right | Directional focus for tiled windows |
| Super+L | Toggle Simple Tile for the focused window |
| Super+M | Toggle maximize |
| Super+1…0 | Switch among 10 workspaces |
| Super+Shift+1…0 | Move focused window to a workspace and follow |
| Super+Ctrl+Alt+E | Expo workspace overview |
| Super+Ctrl+Alt+P | Scale window overview |
| Super+Ctrl+Alt+C | Wayfire desktop cube; Super+Ctrl+Alt+Left/Right rotate it |
| Super+Keypad 1…9/0 | Place/restore windows with Grid |
| Super+Left mouse / Super+Right mouse | Move / resize windows |
| Super+V | Existing Rofi clipboard workflow |
| Alt+Z or Print / Shift+Print | Existing region / full screenshot workflow |
| Super+Alt+Space / Super+Alt+L | Wallpaper picker / lock |
| Volume, brightness, media keys | wpctl / brightnessctl / playerctl |

Wayfire's Simple Tile plugin provides one key per focus direction, so H/J/K stay assigned and Right is the horizontal arrow binding; the other arrow directions cannot be added to those same plugin actions in this config. Tiling is opt-in per window, leaving Wayfire's floating behavior as the default. The Waybar taskbar shows open windows, while Expo provides workspace navigation because Wayfire does not expose the workspace protocol required by Waybar's workspace buttons.

No Wayfire process is started by installation or validation. Select the Wayfire session from the login screen when ready.
