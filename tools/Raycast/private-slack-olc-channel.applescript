#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Private Slack OLC Channel
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Alex Lombry

log "You're in OLC Private Channel"
tell application "Slack"
    activate
    tell application "System Events"
        keystroke "k" using {command down}
        delay 0.5
        keystroke "ft-order-life-cycle-private"
        delay 0.5
        key code 36
        delay 0.5
    end tell
end tell
