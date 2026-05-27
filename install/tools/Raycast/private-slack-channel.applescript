#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Private Slack OLC Channel
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🛰️

# Documentation:
# @raycast.author Alex Lombry

log "You're in Quality Confidence Slack Channel"
tell application "Slack"
    activate
    tell application "System Events"
        keystroke "k" using {command down}
        delay 0.5
        keystroke "quality-confidence-swat"
        delay 0.5
        key code 36
        delay 0.5
    end tell
end tell