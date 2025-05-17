#!/bin/sh

# Check if the .tmux.conf symlink is in place
if [ -L "$HOME/.tmux.conf" ]; then
    exit 0  # installed
else
    exit 1  # not installed
fi
