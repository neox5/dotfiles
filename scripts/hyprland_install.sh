#!/usr/bin/env bash
set -e

DOTFILES_DIR="${HOME}/dotfiles"

PACKAGES=(
    hyprland
    xdg-desktop-portal-hyprland
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
stow -d "$DOTFILES_DIR" hyprland
