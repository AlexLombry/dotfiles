#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Connect to ManoMano VPN
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🕸️

# Documentation:
# @raycast.description VPN Connection at ManoMano with Tunnelblick
# @raycast.author Alex Lombry

tell application "Tunnelblick" to connect "ManoMano"
