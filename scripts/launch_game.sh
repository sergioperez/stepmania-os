#!/usr/bin/bash
GRACEFUL_EXIT_COMMAND="/usr/bin/poweroff"

# Set volume to 100%
/opt/game/raise_volume.sh

# Check if there is a single screen, setting it to main
/opt/game/check_new_screen.sh

# Set all the outputs to the resolution of the main screen
/opt/game/outputs_to_main_res.sh

# Launch game - Poweroff on graceful exit
/usr/sbin/cage /opt/game/itgmania/itgmania && ${GRACEFUL_EXIT_COMMAND}

# If the game crashes, sleep 3s
echo "Game crashed"
sleep 3
