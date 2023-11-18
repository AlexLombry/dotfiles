#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title hello
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Daily routine to start the day
# @raycast.author Alex Lombry

log "Hello World!"

tell application "zoom.us"
	activate
end tell
tell application "System Events"
	tell process "zoom.us"
		tell window "Zoom Meeting"				
		end tell
	end tell
end tell
tell application "Viscosity" to connect "ManoMano"
tell application "Arc"
	tell front window
		tell space "ManoMano" to focus
	end tell
	activate
end tell
