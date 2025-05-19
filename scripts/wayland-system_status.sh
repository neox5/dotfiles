#!/usr/bin/env bash

MODULE="wayland-system"
REQUIRED=(
    xdg-desktop-portal
    xorg-xwayland
    mesa
    libinput
    vulkan-radeon
)

missing=0

for pkg in "${REQUIRED[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        echo "$pkg is not installed"
        missing=1
    fi
done

if [[ $missing -eq 0 ]]; then
    exit 0
else
    exit 1
fi
