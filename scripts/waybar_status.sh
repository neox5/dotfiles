#!/usr/bin/env bash

if pacman -Q waybar &>/dev/null && [[ -f "$HOME/.config/waybar/config" ]]; then
    exit 0
else
    exit 1
fi
