#!/bin/sh
set -e

echo "Linking tmux config via stow..."
stow tmux
echo "tmux install complete."
