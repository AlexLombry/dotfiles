#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Personal Journal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📓

# Documentation:
# @raycast.author Alex Lombry

echo "Journal opening !"

#!/bin/bash
open -a iTerm
osascript -e 'tell application "iTerm" to activate'
osascript -e 'tell application "iTerm" to tell current window of application "iTerm" to create tab with default profile'
osascript -e 'tell application "iTerm" to tell current session of current window of application "iTerm" to write text "cd ~/Desktop && vim captains-log.md"'
