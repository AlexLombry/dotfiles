#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Connect to ManoMano VPN
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description VPN Connection at ManoMano with Viscosity
# @raycast.author Alex Lombry

tell application "Viscosity" to connect "ManoMano"
