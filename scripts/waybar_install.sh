#!/usr/bin/env bash
set -e

DOTFILES_DIR="${HOME}/dotfiles"

# Install waybar
sudo pacman -S --needed --noconfirm waybar

# Link configuration
stow -d "$DOTFILES_DIR" waybar

echo "Waybar installed and configured."
