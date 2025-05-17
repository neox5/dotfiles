#!/usr/bin/env bash

set -e

ZINIT_DIR="${HOME}/.zinit"
FONT_DIR="${HOME}/.local/share/fonts"
DOTFILES="$HOME/dotfiles"

remove_zinit() {
  if [[ -d "$ZINIT_DIR" ]]; then
    echo "Removing Zinit..."
    rm -rf "$ZINIT_DIR"
  else
    echo "Zinit not found. Skipping."
  fi
}

remove_fonts() {
  echo "Removing MesloLGS NF fonts..."
  find "$FONT_DIR" -type f -name "MesloLGS NF*.ttf" -exec rm -f {} \;
  fc-cache -f "$FONT_DIR"
}

remove_stow_symlinks() {
  echo "Removing symlinks created by Stow..."
  cd "$DOTFILES"
  stow -D zsh
}

remove_home_symlinks() {
  echo "Cleaning up Zsh-related symlinks in home directory..."
  [[ -L "$HOME/.zshrc" ]] && rm "$HOME/.zshrc"
  [[ -L "$HOME/.p10k.zsh" ]] && rm "$HOME/.p10k.zsh"
}

main() {
  remove_stow_symlinks
  remove_zinit
  remove_fonts
  remove_home_symlinks
  echo "Zsh configuration cleanup complete."
}

main "$@"
