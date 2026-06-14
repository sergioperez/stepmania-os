#!/usr/bin/bash
#
# Executed by udev: 
# 	Calls outputs_to_main_res.sh when a new monitor is connected
#
export WAYLAND_DISPLAY="wayland-0"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
SCREEN_COUNT_FILE="${HOME}/screen_count"

last_screen_count="$(cat ${SCREEN_COUNT_FILE})"
last_screen_count="${last_screen_count:-"1"}"

# The display manager might not see the screen immediately after
# 	the udev rule has been triggered
# 	We will wait until the number changes (or timeout at 20s)
attempts=0
while [[ "${attempts}" -le 20 ]]
do
	screens_json="$(wlr-randr --json)"
	screen_count=$(jq -r '. | length' <<< "${screens_json}")
	attempts=$(( attempts + 1 ))
	[[ "${screen_count}" != "${last_screen_count}" ]] && break
	sleep 1
done

echo "Screen count: ${screen_count}"
/opt/game/outputs_to_main_res.sh
