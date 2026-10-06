#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
target_dir="$HOME/.config/wayfire"
auto_yes=false
check_only=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [--check] [--yes]

  --check  Report package and external-file requirements without changing anything.
  --yes    Skip the install confirmation (sudo may still ask for a password).
  -h       Show this help.
EOF
}

while (($#)); do
    case "$1" in
        --check) check_only=true ;;
        --yes) auto_yes=true ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

if ! command -v pacman >/dev/null 2>&1; then
    printf 'This installer supports Arch Linux and pacman.\n' >&2
    exit 1
fi

repo_packages=(
    wayfire waybar kitty dolphin rofi kdenlive neovim
    wl-clipboard cliphist grim slurp swaybg swayidle swaync hyprlock
    network-manager-applet polkit-gnome libnotify
    pipewire pipewire-pulse wireplumber brightnessctl playerctl jq procps-ng
    networkmanager btop pulsemixer bluetui cava calcurse yazi python
)

missing_repo=()
unavailable_repo=()
for package in "${repo_packages[@]}"; do
    if pacman -Q "$package" >/dev/null 2>&1; then
        continue
    elif pacman -Si "$package" >/dev/null 2>&1; then
        missing_repo+=("$package")
    else
        unavailable_repo+=("$package")
    fi
done

missing_aur=()
if ! pacman -Q helium-browser-bin >/dev/null 2>&1; then
    if command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1; then
        missing_aur+=(helium-browser-bin)
    fi
fi

missing_shared=()
check_shared() { [[ -e "$1" ]] || missing_shared+=("$1"); }
check_shared "$HOME/.config/rofi/launchers/launcher.sh"
check_shared "$HOME/.config/rofi/clipboard/clipboard.sh"
check_shared "$HOME/.config/rofi/wallpaper/wallpaper.rasi"
check_shared "$HOME/.config/rofi/powermenu/type-2/style-5.rasi"
check_shared "$HOME/.config/hypr/scripts/screenshot.sh"
check_shared "$HOME/.config/hyprlock/hyprlock.template.conf"
check_shared "$HOME/.config/waybar/scripts/skull.sh"
check_shared "$HOME/.config/waybar/scripts/catloop.sh"
check_shared "$HOME/.config/waybar/scripts/art-animation.py"
check_shared "$HOME/.config/waybar/scripts/notifications.sh"
check_shared "$HOME/.config/waybar/scripts/tui.sh"
check_shared "$HOME/.local/bin/battery-guardian"
check_shared "$HOME/Pictures/Wallpapers/CozyPixels/Catppuccin/Space & Cosmic"

printf 'Wayfire setup requirements:\n'
if ((${#missing_repo[@]})); then
    printf '  Missing official packages: %s\n' "${missing_repo[*]}"
else
    printf '  All listed official packages are installed.\n'
fi
if ((${#unavailable_repo[@]})); then
    printf '  Not found in configured repositories: %s\n' "${unavailable_repo[*]}"
fi
if ((${#missing_aur[@]})); then
    printf '  Missing AUR package: %s\n' "${missing_aur[*]}"
elif ! pacman -Q helium-browser-bin >/dev/null 2>&1; then
    printf '  Missing AUR package: helium-browser-bin (install with yay or paru).\n'
fi
if ((${#missing_shared[@]})); then
    printf '  Existing shared workflows/assets not found (not copied or changed):\n'
    printf '    %s\n' "${missing_shared[@]}"
else
    printf '  Shared Rofi, Hyprlock, Waybar, screenshot, battery, and wallpaper files are present.\n'
fi

if [[ "$check_only" == true ]]; then
    ((${#unavailable_repo[@]} == 0)) || exit 1
    exit 0
fi
if ((${#unavailable_repo[@]})); then
    printf 'Cannot install: package lookup failed for %s\n' "${unavailable_repo[*]}" >&2
    exit 1
fi
if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
    printf 'Target exists and is not a directory: %s\n' "$target_dir" >&2
    exit 1
fi

if [[ "$auto_yes" != true ]]; then
    cat <<EOF

This installs missing packages and copies the Wayfire files into:
  $target_dir

Matching files will be replaced without backups. Shared application and other
compositor configurations will remain untouched.
EOF
    read -r -p 'Continue? [y/N] ' answer
    [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]] || { echo 'Cancelled.'; exit 0; }
fi

if ((${#missing_repo[@]})); then
    sudo pacman -S --needed -- "${missing_repo[@]}"
fi
if ((${#missing_aur[@]})); then
    if command -v yay >/dev/null 2>&1; then
        yay -S --needed -- "${missing_aur[@]}"
    else
        paru -S --needed -- "${missing_aur[@]}"
    fi
fi

install -d "$target_dir/scripts"
install -m 644 "$repo_dir/wayfire.ini" "$repo_dir/waybar.jsonc" "$repo_dir/waybar.css" "$target_dir/"
install -m 755 "$repo_dir/scripts/"*.sh "$target_dir/scripts/"
printf '\nWayfire configuration installed in %s\n' "$target_dir"
printf 'Review the external-file notices above. Nothing outside that directory was copied or replaced.\n'
