#!/usr/bin/bash

# Raise volume
cards=$(ls /proc/asound | grep '^card[0-9]\+$' | cut -d "d" -f2)
for card in ${cards}
do
        controls=$(amixer -c ${card} controls | grep -oE 'numid=[0-9]+' | cut -d '=' -f2)
        for control in ${controls}
        do
                amixer -c ${card} cset numid="${control}" 100% unmute
        done
done

# Keep the game open
while [ true ]
do
	# Start game
	echo "Starting ITGMania"
	if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
	  weston --backend drm --shell=kiosk --xwayland  -- /opt/game/itgmania/itgmania
	fi
	echo "Game stopped - Restarting"
done

