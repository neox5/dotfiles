#!/usr/bin/env bash
set -e # exit immediately on error

echo "🔧 Installing basic packages..."
sudo apt update
sudo apt install make stow neovim

echo "💻 Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi


