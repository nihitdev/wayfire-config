#!/usr/bin/env bash
set -euo pipefail

template="$HOME/.config/hyprlock/hyprlock.template.conf"
config="$HOME/.config/wayfire/hyprlock.conf"
wall=""

pgrep -u "$(id -u)" -x hyprlock >/dev/null && exit 0

if [[ -f "$HOME/.config/wayfire/current-wallpaper" ]]; then
    wall="$(realpath -- "$HOME/.config/wayfire/current-wallpaper")"
elif [[ -r "$HOME/.cache/current-wallpaper" ]]; then
    IFS= read -r wall < "$HOME/.cache/current-wallpaper" || true
elif [[ -f "$HOME/.config/hypr/current-wallpaper" ]]; then
    wall="$(realpath -- "$HOME/.config/hypr/current-wallpaper")"
fi
[[ -f "$wall" ]] || wall=""

escaped="${wall//\\/\\\\}"
escaped="${escaped//&/\\&}"
escaped="${escaped//|/\\|}"
sed "s|__WALLPAPER__|$escaped|g" "$template" > "$config"
exec hyprlock --config "$config"
