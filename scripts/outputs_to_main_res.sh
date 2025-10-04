#!/usr/bin/bash
#
# Given a "Main output", sets all the other outputs to its mode
#
SM_PREFS_FILE="${HOME}/.itgmania/Save/Preferences.ini"
MAIN_OUTPUT_FILE="${HOME}/main_monitor"

settings_interlaced="$(grep '^Interlaced=' "${SM_PREFS_FILE}" | cut -f2 -d'=' | grep -o '[0-1]')"
if [[ "${settings_interlaced}" == 1 ]]
then
	echo "Interlaced set to 1. outputs_to_itgmania_res.sh does not support this scenario yet"
	exit 0
fi

screens_json="$(wlr-randr --json)"
system_displays="$(jq -r ".[].name" <<< "${screens_json}")"

main_output=$(cat "${MAIN_OUTPUT_FILE}")

mode=$(jq -r ".[] | select(.name == \"${main_output}\") | .modes[] | select(.current)" <<< "${screens_json}")
width=$(jq -r .width <<< "${mode}")
height=$(jq -r .height <<< "${mode}")
refresh=$(jq -r .refresh <<< "${mode}")

# Set the displays to the main output resolution
IFS=$'\n'
while IFS= read -r display
do
	wlr-randr --output="${display}" --pos=0,0

	# Do not change the main output resolution
	if [[ "${display}" == "${main_output}" ]]
	then
		continue
	fi

	if ! wlr-randr --output "${display}" --custom-mode="${width}x${height}@${refresh}" 
	then
		echo "Failed to set monitor (${display}) resolution. Trying with automatic refresh rate"
		wlr-randr --output "${display}" --custom-mode="${width}x${height}"
	fi
done <<< "${system_displays}"
