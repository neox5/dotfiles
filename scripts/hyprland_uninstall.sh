#!/usr/bin/env bash
set -e

DOTFILES_DIR="${HOME}/dotfiles"

PACKAGES=(
    hyprland
    xdg-desktop-portal-hyprland
)

for pkg in "${PACKAGES[@]}"; do
    pacman -Q "$pkg" &>/dev/null && sudo pacman -Rs --noconfirm "$pkg"
done

stow -D -d "$DOTFILES_DIR" hyprland
