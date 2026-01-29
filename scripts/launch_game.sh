#!/usr/bin/bash

# Set volume to 100%
/opt/game/raise_volume.sh

# Check if there is a single screen, setting it to main
/opt/game/check_new_screen.sh

# Set all the outputs to the resolution of the main screen
/opt/game/outputs_to_main_res.sh

# Launch game
/usr/sbin/cage /opt/game/itgmania/itgmania
