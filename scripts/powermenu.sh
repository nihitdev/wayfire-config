#!/usr/bin/env bash
set -euo pipefail

theme="$HOME/.config/rofi/powermenu/type-2/style-5.rasi"
lock='󰌾'
suspend='󰒲'
logout='󰍃'
reboot=''
shutdown=''
yes=''
no=''

choice="$(printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" |
    rofi -dmenu -p "Uptime: $(uptime -p | sed 's/^up //')" -mesg 'A R C H N E M E S I S' -theme "$theme")" || exit 0

case "$choice" in
    "$lock") exec "$HOME/.config/wayfire/scripts/lock.sh" ;;
    "$suspend"|"$logout"|"$reboot"|"$shutdown") ;;
    *) exit 0 ;;
esac

confirm="$(printf '%s\n' "$yes" "$no" |
    rofi -dmenu -p Confirmation -mesg 'Are you sure?' -theme "$theme" \
        -theme-str 'window { location: center; anchor: center; fullscreen: false; width: 350px; }' \
        -theme-str 'mainbox { children: [ "message", "listview" ]; }' \
        -theme-str 'listview { columns: 2; lines: 1; }' \
        -theme-str 'element-text { horizontal-align: 0.5; }' \
        -theme-str 'textbox { horizontal-align: 0.5; }')" || exit 0
[[ "$confirm" == "$yes" ]] || exit 0

case "$choice" in
    "$suspend")  exec systemctl suspend ;;
    "$logout")   exec wayland-logout ;;
    "$reboot")   exec systemctl reboot ;;
    "$shutdown") exec systemctl poweroff ;;
esac
