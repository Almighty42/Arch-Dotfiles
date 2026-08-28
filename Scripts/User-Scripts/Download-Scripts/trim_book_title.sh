#!/usr/bin/env bash

input=$(xclip -selection clipboard -o)

output=$(echo "$input" \
    | sed 's/ /_/g' \
    | sed 's/[()]//g' \
    | sed 's/\./_/g')

# Copy the transformed output back to the clipboard
echo "$output" | xclip -selection clipboard
