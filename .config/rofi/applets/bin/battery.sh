#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Battery

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Battery Info
#battery="`acpi -b | cut -d',' -f1 | cut -d':' -f1`"
#battery="$(acpi -b | cut -d',' -f1)"
status="`acpi -b | sed -n 's/^Battery [0-9]*: \([^,]*\),.*/\1/p'`"
#percentage="`acpi -b | cut -d',' -f2 | tr -d ' ',\%`"
#time="`acpi -b | cut -d',' -f3`"

#if [[ -z "$time" ]]; then
	time=' Fully Charged'
#fi

# Theme Elements
prompt="$status"

#acpi -b | while IFS= read -r line; do
#    battery=$(echo "$line" | cut -d':' -f1)
#    percentage=$(echo "$line" | cut -d',' -f2 | tr -d ' %')
#    echo "$battery : $percentage%"
#done

#echo "$battery : $percentage"
#mesg="${battery}: ${percentage}%"




# Initialize an empty string to accumulate messages
mesg=""

# Read the output of 'acpi -b' line by line
while IFS= read -r line; do
    # Extract battery identifier
    battery=$(echo "$line" | cut -d':' -f1)
    
    # Extract percentage and remove spaces and percent sign
    percentage=$(echo "$line" | cut -d',' -f2 | tr -d ' %')
    
    # Append the formatted battery information to the message string using printf -v
    printf -v mesg "%s%s: %s%%\n" "$mesg" "$battery" "$percentage"
done < <(acpi -b)

# At this point, 'mesg' contains the formatted battery information with proper newlines
# You can now use 'mesg' in your applet as needed


if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'
	list_row='4'
	win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
	list_col='1'
	list_row='4'
	win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='4'
	win_width='500px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='4'
	list_row='1'
	win_width='550px'
fi

# Charging Status
active=""
urgent=""
if [[ $status = *"Charging"* ]]; then
    active="-a 1"
    ICON_CHRG=""
elif [[ $status = *"Full"* ]]; then
    active="-u 1"
    ICON_CHRG=""
else
    urgent="-u 1"
    ICON_CHRG=""
fi

# Discharging
if [[ $percentage -ge 5 ]] && [[ $percentage -le 19 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage -ge 20 ]] && [[ $percentage -le 39 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage -ge 40 ]] && [[ $percentage -le 59 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage -ge 60 ]] && [[ $percentage -le 79 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage -ge 80 ]] && [[ $percentage -le 100 ]]; then
    ICON_DISCHRG=""
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1=" Remaining ${percentage}%"
	option_2=" $status"
	option_3=" Power Manager"
	option_4=" Diagnose"
else
	option_1="$ICON_DISCHRG"
	option_2="$ICON_CHRG"
	option_3=""
	option_4=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str "textbox-prompt-colon {str: \"$ICON_DISCHRG\";}" \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		${active} ${urgent} \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4" | rofi_cmd
}

# Execute Command
run_cmd() {
	polkit_cmd="pkexec env PATH=$PATH DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY"
	if [[ "$1" == '--opt1' ]]; then
		notify-send -u low " Remaining : ${percentage}%"
	elif [[ "$1" == '--opt2' ]]; then
		notify-send -u low "$ICON_CHRG Status : $status"
	elif [[ "$1" == '--opt3' ]]; then
		xfce4-power-manager-settings
	elif [[ "$1" == '--opt4' ]]; then
		${polkit_cmd} alacritty -e powertop
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
esac


