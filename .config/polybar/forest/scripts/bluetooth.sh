#!/bin/bash

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
  echo ""
else
  # Check if any Bluetooth device is connected
  if bluetoothctl info | grep -q 'Connected: yes'; then
    DEVICE=$(bluetoothctl info | awk -F': ' '/Alias:/ { print $2 }')
    echo "%{F#88c0d0}"
  else
    echo "%{F#bf616a}" 
  fi
fi
