#!/bin/bash

# Preview script for tmuxp projects
CONFIG_DIR="$HOME/.config/tmuxp"
FILE="$CONFIG_DIR/$1.yaml"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE does not exist."
    exit 1
fi

# Display YAML file content with enhanced styling
if command -v bat &> /dev/null; then
    bat --color=always --style="numbers,changes,header" --theme="TokyoNightMoon" \
        --wrap=auto --tabs=2 "$FILE"
else
    # Fallback with basic formatting using less or cat
    if command -v less &> /dev/null; then
        cat "$FILE" | less -R
    else
        cat "$FILE"
    fi
fi
