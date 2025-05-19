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

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
