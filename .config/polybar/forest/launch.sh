#!/usr/bin/env bash

DIR="$HOME/.config/polybar/forest"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

# Launch the bar (no leading /)
polybar main -c "$DIR/config.ini" 2>&1 | tee -a /tmp/polybar-forest.log &
