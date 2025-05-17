#!/usr/bin/env bash

set -e

DOTFILES_DIR="${HOME}/dotfiles"
ZINIT_DIR="${HOME}/.zinit"
FONT_DIR="${HOME}/.local/share/fonts"
MESLO_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"

install_zinit() {
  if [[ ! -d "$ZINIT_DIR" ]]; then
    echo "Installing Zinit..."
    mkdir -p "$ZINIT_DIR"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_DIR/bin"
  else
    echo "Zinit already installed."
  fi
}

install_fonts() {
  mkdir -p "$FONT_DIR"
  cd "$FONT_DIR"
  for type in Regular Bold Italic "Bold Italic"; do
    file="MesloLGS NF ${type}.ttf"
    url="${MESLO_URL}/${file// /%20}"
    if [[ ! -f "$file" ]]; then
      echo "Downloading $file..."
      curl -fLo "$file" "$url"
    fi
  done

  echo "Fonts installed to $FONT_DIR"
  fc-cache -f "$FONT_DIR"
}


add_stow_symlinks() {
  echo "Add symlinks with Stow..."
  cd "$DOTFILES_DIR"
  stow zsh
}

main() {
  echo "Setting up Zsh environment..."
  install_zinit
  install_fonts
  add_stow_symlinks
  echo "Done. Please restart your terminal to run the zinit installation."
}

main "$@"
