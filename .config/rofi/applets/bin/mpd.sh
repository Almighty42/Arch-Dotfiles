#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : MPD (music)

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
status="`playerctl status`"
if [[ "$status" == "No players found" ]]; then
	prompt='Offline'
	mesg="Player is Offline"
else
	prompt="`playerctl metadata artist`"
	mesg="`playerctl metadata title` :: `playerctl metadata album`"
fi

if [[ ( "$theme" == *'type-1'* ) || ( "$theme" == *'type-3'* ) || ( "$theme" == *'type-5'* ) ]]; then
	list_col='1'
	list_row='6'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='6'
	list_row='1'
fi

# Options

echo "${status}"

layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	if [[ ${status} == "Playing" ]]; then
		option_1=" Pause"
	else
		option_1=" Play"
	fi
	option_2=" Stop"
	option_3=" Previous"
	option_4=" Next"
	option_5=" Repeat"
	option_6=" Random"
else
	if [[ ${status} == "Playing" ]]; then
		option_1=""
	else
		option_1=""
	fi
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Toggle Actions
active=''
urgent=''
# Repeat

loop_status_value=$(playerctl loop)

if [[ ${loop_status_value} == "Playlist" ]]; then
    active="-a 4"
elif [[ ${loop_status_value} == "None" ]]; then
    urgent="-u 4"
else
    option_5=""
fi

shuffle_status_value=$(playerctl shuffle)

# Random
if [[ ${shuffle_status_value} == "On" ]]; then
    [ -n "$active" ] && active+=",5" || active="-a 5"
elif [[ ${shuffle_status_value} == "Off" ]]; then
    [ -n "$urgent" ] && urgent+=",5" || urgent="-u 5"
else
    option_6=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		${active} ${urgent} \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		#mpc -q toggle && notify-send -u low -t 1000 " `mpc current`"
		playerctl play-pause
	elif [[ "$1" == '--opt2' ]]; then
		#mpc -q stop
		playerctl stop
	elif [[ "$1" == '--opt3' ]]; then
		#mpc -q prev && notify-send -u low -t 1000 " `mpc current`"
		playerctl previous
	elif [[ "$1" == '--opt4' ]]; then
		#mpc -q next && notify-send -u low -t 1000 " `mpc current`"
		playerctl next
	elif [[ "$1" == '--opt5' ]]; then
		echo "Hello option 5"
		loop_status=$(playerctl loop)
		if [[ "$loop_status" == "None" ]]; then
			# Loop is disabled
			playerctl loop playlist
		elif [[ "$loop_status" == "Playlist" ]]; then
			# Looping current track
			playerctl loop none
		fi
		#mpc -q repeat
	elif [[ "$1" == '--opt6' ]]; then
		echo "Hello option 6"
		shuffle_status=$(playerctl shuffle)
		if [[ "$shuffle_status" == "Off" ]]; then
			# Loop is disabled
			playerctl shuffle on
		elif [[ "$shuffle_status" == "On" ]]; then
			# Looping current track
			playerctl shuffle off
		fi
		#mpc -q random
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
		$HOME/.config/rofi/applets/bin/mpd.sh
        ;;
    $option_2)
		run_cmd --opt2
		$HOME/.config/rofi/applets/bin/mpd.sh
        ;;
    $option_3)
		run_cmd --opt3
		$HOME/.config/rofi/applets/bin/mpd.sh
        ;;
    $option_4)
		run_cmd --opt4
		$HOME/.config/rofi/applets/bin/mpd.sh
        ;;
    $option_5)
		run_cmd --opt5
		$HOME/.config/rofi/applets/bin/mpd.sh
        ;;
    $option_6)
		run_cmd --opt6
		$HOME/.config/rofi/applets/bin/mpd.sh
        ;;
esac
