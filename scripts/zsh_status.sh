#!/usr/bin/env bash

if [[ -L "$HOME/.zshrc" && -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
  exit 0
else
  exit 1
fi
