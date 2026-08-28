#!/usr/bin/env bash
set -e

THEME="$1"

if [ -z "$THEME" ]; then
  echo "Usage: $0 THEME_NAME" >&2
  exit 1
fi

THEME_DIR="$HOME/Other/themes/$THEME"

if [ ! -d "$THEME_DIR" ]; then
  echo "Theme dir not found: $THEME_DIR" >&2
  exit 1
fi

# Xresources
if [ -f "$THEME_DIR/.Xresources" ]; then
  cp "$THEME_DIR/.Xresources" "$HOME/.Xresources"
  xrdb -merge "$HOME/.Xresources"
fi

# Wallpaper (png or jpg)
mkdir -p "$HOME/.config/awesome"
rm -f "$HOME/.config/awesome/wallpaper.png"

if [ -f "$THEME_DIR/wallpaper.png" ]; then
  cp "$THEME_DIR/wallpaper.png" "$HOME/.config/awesome/wallpaper.png"
elif [ -f "$THEME_DIR/wallpaper.jpg" ]; then
  convert "$THEME_DIR/wallpaper.jpg" "$HOME/.config/awesome/wallpaper.png"
fi

# For Neovim theme integration
NVIM_THEME_DIR="$HOME/.config/nvim"

# Example: write scheme + background; adjust per theme
case "$THEME" in
  gruvbox_light)
    echo "gruvbox-material light" > "$NVIM_THEME_DIR/current_theme"
    ;;
  gruvbox_dark)
    echo "gruvbox-material dark" > "$NVIM_THEME_DIR/current_theme"
    ;;
  catppuccin_latte)
    echo "catppuccin latte" > "$NVIM_THEME_DIR/current_theme"
    ;;
  catppuccin_mocha)
    echo "catppuccin mocha" > "$NVIM_THEME_DIR/current_theme"
    ;;
  catppuccin_frappe)
    echo "catppuccin frappe" > "$NVIM_THEME_DIR/current_theme"
    ;;
  catppuccin_macchiato)
    echo "catppuccin macchiato" > "$NVIM_THEME_DIR/current_theme"
    ;;
  everforest_light)
    echo "everforest light" > "$NVIM_THEME_DIR/current_theme"
    ;;
  everforest_dark)
    echo "everforest dark" > "$NVIM_THEME_DIR/current_theme"
    ;;
  tokyonight-moon)
    echo "tokyonight dark" > "$NVIM_THEME_DIR/current_theme"
    ;;
  *)
    echo "$THEME dark" > "$NVIM_THEME_DIR/current_theme"
    ;;
esac

# Reload awesome (Mod4+Ctrl+r default, or via awesome-client)
awesome-client 'awesome.restart()'

# Restart polybar
~/.config/polybar/forest/launch.sh
