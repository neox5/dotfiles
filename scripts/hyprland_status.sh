
#!/usr/bin/env bash

MODULE="hyprland"
CONFIG="$HOME/.config/hypr/hyprland.conf"

check_installed() {
    pacman -Q hyprland &>/dev/null
}

check_config_symlink() {
    # We check if the config file exists, even if it's inside a symlinked dir
    [ -e "$CONFIG" ]
}

if ! check_installed; then
    exit 1
fi

if ! check_config_symlink; then
    exit 1
fi
exit 0
