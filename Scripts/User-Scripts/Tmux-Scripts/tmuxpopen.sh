#!/bin/bash

# Fuzzy finder for tmuxp projects in ~/.config/tmuxp
CONFIG_DIR="$HOME/.config/tmuxp"
FUZZY_FINDER="fzf"

# Check if fzf is installed
if ! command -v $FUZZY_FINDER &> /dev/null; then
    echo "Error: fzf is not installed."
    exit 1
fi

# Check if config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: $CONFIG_DIR does not exist."
    exit 1
fi

# Find .yaml files and use fzf with custom style and preview
selected=$(find "$CONFIG_DIR" -type f -name "*.yaml" -exec basename {} .yaml \; | $FUZZY_FINDER --style full --preview '~/Scripts/User-Scripts/Tmux-Scripts/fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}' --prompt="Select tmuxp project: ")

# Load selected tmuxp session
if [ -n "$selected" ]; then
    tmuxp load "$selected"
else
    echo "No project selected."
    exit 1
fi
