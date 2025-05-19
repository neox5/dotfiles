#!/usr/bin/env bash
set -e

DOTFILES_DIR="${HOME}/dotfiles"

PACKAGES=(
    xdg-desktop-portal
    xorg-xwayland
    mesa
    libinput
    vulkan-radeon
)

for pkg in "${PACKAGES[@]}"; do
    pacman -Q "$pkg" &>/dev/null && sudo pacman -Rs --noconfirm "$pkg"
done
