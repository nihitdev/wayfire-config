#!/usr/bin/env bash
set -euo pipefail

uid="$(id -u)"
while IFS= read -r pid; do
    [[ -r "/proc/$pid/environ" ]] || continue
    if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -Fxq "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"; then
        exit 0
    fi
done < <(pgrep -u "$uid" -x swaybg || true)

wall="$HOME/.config/wayfire/current-wallpaper"
[[ -f "$wall" ]] || wall="$HOME/.config/hypr/current-wallpaper"
[[ -f "$wall" ]] || wall="$HOME/.config/mango/wallpapers/default.png"
[[ -f "$wall" ]] || exit 0

swaybg -i "$wall" -m fill -c 191724 >/dev/null 2>&1 &
