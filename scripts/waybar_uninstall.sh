#!/usr/bin/env bash
set -e

DOTFILES_DIR="${HOME}/dotfiles"

# Remove configuration
stow -D -d "$DOTFILES_DIR" waybar

# Optionally remove package
# sudo pacman -Rs --noconfirm waybar

echo "Waybar configuration removed."
