#!/usr/bin/env bash
set -euo pipefail

wall_dir="$HOME/Pictures/Wallpapers/CozyPixels/Catppuccin/Space & Cosmic"
current="$HOME/.config/wayfire/current-wallpaper"
theme="$HOME/.config/rofi/wallpaper/wallpaper.rasi"

if [[ ! -d "$wall_dir" ]]; then
    notify-send -a Wallpaper "Wallpaper directory not found" "$wall_dir"
    exit 1
fi

mapfile -d '' -t walls < <(
    find "$wall_dir" -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0
)
((${#walls[@]} > 0)) || {
    notify-send -a Wallpaper "No wallpapers found" "$wall_dir"
    exit 1
}

selection="$(
    for wall in "${walls[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(basename "$wall")" "$wall"
    done | rofi -dmenu -i -show-icons -p '󰸉  Wallpaper' -theme "$theme"
)" || exit 0
[[ -n "$selection" ]] || exit 0

wall=""
for candidate in "${walls[@]}"; do
    if [[ "$(basename "$candidate")" == "$selection" ]]; then
        wall="$candidate"
        break
    fi
done
[[ -n "$wall" ]] || exit 1

ln -sfn -- "$wall" "$current"
while IFS= read -r pid; do
    [[ -r "/proc/$pid/environ" ]] || continue
    if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -Fxq "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"; then
        kill "$pid" 2>/dev/null || true
    fi
done < <(pgrep -u "$(id -u)" -x swaybg || true)

exec swaybg -i "$wall" -m fill -c 191724
