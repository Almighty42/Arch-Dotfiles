#!/bin/sh
raw=$(awesome-client '
local tag = mouse.screen.selected_tag
return tag and tag.layout.name or "unknown"
' 2>/dev/null)
layout=$(echo "$raw" | sed 's/^.*string "\(.*\)".*$/\1/' | tr -d ' \n')

case "$layout" in
    cornernw)      echo "󰧄 " ;;
    cornerne)      echo "󰧆 " ;;
    cornersw)      echo "󰦸 " ;;
    cornerse)      echo "󰦺 " ;;
    floating)      echo "󰞥 " ;;
    tile)          echo "󱂫 " ;;
    tileleft)      echo "󱂪 " ;;
    tilebottom)    echo "󱂩 " ;;
    tiletop)       echo "󱔓 " ;;
    max)           echo "󰊔 " ;;
    fullscreen) echo " " ;;
    magnifier)     echo "󰍉 " ;;
    fairv)          echo " " ;;
    fairh)echo "󰽿 " ;;
    # *)             echo "󰽿 " ;;
esac
