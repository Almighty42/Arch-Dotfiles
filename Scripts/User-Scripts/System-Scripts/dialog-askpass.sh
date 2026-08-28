#!/bin/bash
dialog --clear --title "Sudo Password" --insecure --passwordbox "Enter your sudo password:" 8 40 3>&1 1>&2 2>&3
