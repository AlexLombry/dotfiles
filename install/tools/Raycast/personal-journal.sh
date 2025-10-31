#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Personal Journal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📓

# Documentation:
# @raycast.author Alex Lombry

# Open the Ghostty application
# open -a "Ghostty"
# osascript -e 'tell application "Ghostty" to activate'
# osascript -e 'tell application "Ghostty" to tell current window to create tab with default profile'
# osascript -e 'tell application "Ghostty" to tell current session of current window to write text "cd ~/Desktop && vim captains-log.md"'

open -na Ghostty --args -e /opt/homebrew/bin/nvim "$HOME/Desktop/captains-log.md"
