#!/usr/bin/bash
#
# When a single monitor is detected:
# 	Checks if this is the same monitor as the last "single monitor start"
# 		If the monitor is the previous one -> Try to set monitor to ITGMania resolution with its preferred refresh rate
# 		If the monitor is not the prevous one -> Set monitor+ITGMania resolution to preferred one
# 	If there are two monitors:
# 		This script does nothing
SM_PREFS_FILE="${HOME}/.itgmania/Save/Preferences.ini"
HASH_MONITOR_FILE="${HOME}/hash_monitors"
MAIN_MONITOR_FILE="${HOME}/main_monitor"

screens_json="$(wlr-randr --json)"
screens_count=$(jq -r '. | length' <<< "${screens_json}")
echo "screens_count: ${screens_count}"

# Do not act if there is more than one screen
if [[ "${screens_count}" != "1" ]]
then
	echo "Screen count number different from 1: (${screens_count}) - Not handling resolution settings automatically"
	exit 0
fi


# Gather monitor info
display_name=$(jq -r '.[0].name' <<< "${screens_json}")
preferred_mode=$(jq -c ".[] | select(.name == \"${display_name}\") | .modes[] | select(.preferred)" <<< "${screens_json}")
# If no default resolution -> Fallback to 640x480 
if [[ -z "${preferred_mode}" ]]
then
	echo "Monitor (${display_name}): Fallback to 640x480"
	native_height=480
	native_width=640
	native_refresh=60
else 	
	native_height=$(jq -r '.height' <<< "${preferred_mode}")
	native_width=$(jq -r '.width' <<< "${preferred_mode}")
	native_refresh=$(jq -r '.refresh' <<< "${preferred_mode}")
	aspect_ratio=$(echo "scale=6; ${native_width}/${native_height}" | bc)
	echo "Monitor (${display_name}): Supports native resolution ${native_width}x${native_height}"
fi

# If a different monitor is found - Set ITGMania resolution to the new monitor
hash_monitors=$(cat "${HASH_MONITOR_FILE}")
newhash=$(jq -c '.[] | {name, description, make, model, serial}' <<< "${screens_json}" | cksum | cut -d' ' -f1)
if [[ "${hash_monitors}" != "${newhash}" ]]
then
	echo "${display_name}" > "${MAIN_MONITOR_FILE}"
	# Store hash to avoid running this twice over the same monitor
	echo "${newhash}" > "${HASH_MONITOR_FILE}"

	echo "Found new main screen (${display_name}), setting game and monitor resolution"

	sed -i "s/^DisplayAspectRatio.*/DisplayAspectRatio=${aspect_ratio}/" ${SM_PREFS_FILE}
	sed -i "s/^DisplayWidth.*/DisplayWidth=${native_width}/" ${SM_PREFS_FILE}
	sed -i "s/^DisplayHeight.*/DisplayHeight=${native_height}/" ${SM_PREFS_FILE}

	# Set monitor to preferred resolution
	wlr-randr --output "${display_name}" --preferred
else
	# In this scenario, the monitor is not new -> Try to adjust the monitor resolution to the game resolution
	settings_width="$(grep '^DisplayWidth=' "${SM_PREFS_FILE}" | cut -f2 -d'=' | grep -Eo '[0-9]+')"
	settings_height="$(grep '^DisplayHeight=' "${SM_PREFS_FILE}" | cut -f2 -d'=' | grep -Eo '[0-9]+')"
	if [[ "${settings_width}" == "${native_width}" ]] && [[ "${settings_height}" == ${native_height} ]]
	then
		echo "Setting main monitor (${display_name}) to preferred resolution (${native_width}x${native_height}@${native_refresh})"
		wlr-randr --output "${display_name}" --preferred
	else
		echo "Setting main monitor (${display_name} to game resolution (${settings_width}x${settings_height}- Fallback refresh rate)"
		wlr-randr --output "${display_name}" --mode "${settings_width}x${settings_height}"
	fi
fi
