#!/bin/sh

echo "Unlinking tmux config via stow..."
stow -D tmux
echo "tmux uninstall complete."
