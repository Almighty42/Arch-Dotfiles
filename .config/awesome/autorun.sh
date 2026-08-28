#!/bin/sh

run() {
  if ! pgrep -f "$1"; then
    "$@" &
  fi
}

# Screen locker — kill existing instance first to avoid stacking
pkill xss-lock
xss-lock -- betterlockscreen -l &

# Idle timeout: lock after 10 minutes (600 seconds)
xset s 600 600

# Hide cursor after 3 seconds of inactivity
run unclutter -idle 3 -root

# Browser tabs 
qutebrowser --target tab \
  'https://inbox.purelymail.com/?_task=mail&_mbox=INBOX' \
  'https://server.budget/budget' \
  'https://cronometer.com' &
