#!/usr/bin/bash

# Set volume to 100%
/opt/game/scripts/audio/raise_volume.sh

# Check if there is a single screen, setting it to main
/opt/game/scripts/video/check_new_screen.sh

# Set all the outputs to the resolution of the main screen
/opt/game/scripts/video/outputs_to_main_res.sh

# Launch game - Poweroff on graceful exit
/opt/game/itgmania/itgmania
