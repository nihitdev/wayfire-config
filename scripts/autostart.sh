#!/usr/bin/env bash
set -euo pipefail

uid="$(id -u)"
display="${WAYLAND_DISPLAY:-}"

same_session_process() {
    local name="$1" pid
    while IFS= read -r pid; do
        [[ -r "/proc/$pid/environ" ]] || continue
        if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -Fxq "WAYLAND_DISPLAY=$display"; then
            return 0
        fi
    done < <(pgrep -u "$uid" -x "$name" 2>/dev/null || true)
    return 1
}

start_background() {
    "$@" >/dev/null 2>&1 &
}

"$HOME/.config/wayfire/scripts/start-wallpaper.sh"

if ! same_session_process swayidle; then
    start_background swayidle -w \
        timeout 300 "$HOME/.config/wayfire/scripts/lock.sh" \
        timeout 1800 'systemctl suspend' \
        before-sleep "$HOME/.config/wayfire/scripts/lock.sh"
fi

for type in text image/png; do
    watcher=false
    while IFS= read -r pid; do
        [[ -r "/proc/$pid/environ" && -r "/proc/$pid/cmdline" ]] || continue
        if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -Fxq "WAYLAND_DISPLAY=$display" \
            && tr '\0' ' ' < "/proc/$pid/cmdline" | grep -Fq "wl-paste --type $type --watch cliphist store"; then
            watcher=true
            break
        fi
    done < <(pgrep -u "$uid" -x wl-paste 2>/dev/null || true)
    if [[ "$watcher" == false ]]; then
        start_background wl-paste --type "$type" --watch cliphist store
    fi
done

if [[ -x "$HOME/.local/bin/battery-guardian" ]] && ! pgrep -u "$uid" -f '[b]attery-guardian' >/dev/null; then
    start_background "$HOME/.local/bin/battery-guardian"
fi

if ! pgrep -u "$uid" -f '[/]polkit-gnome-authentication-agent-1|[/]polkit-kde-authentication-agent-1|[/]polkit-kde-agent' >/dev/null; then
    if [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
        start_background /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    fi
fi

if systemctl --user cat swaync.service >/dev/null 2>&1; then
    systemctl --user is-active --quiet swaync.service || systemctl --user start swaync.service
elif ! pgrep -u "$uid" -x swaync >/dev/null; then
    start_background swaync
fi

if ! same_session_process waybar; then
    start_background waybar -c "$HOME/.config/wayfire/waybar.jsonc" -s "$HOME/.config/wayfire/waybar.css"
fi
