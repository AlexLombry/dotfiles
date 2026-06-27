#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.icon assets/recenter-raycast-window.png
# @raycast.title Center Raycast Window Position
# @raycast.description Center the main Raycast window within the visible screen area.
# @raycast.packageName Raycast
# @raycast.mode silent

set -euo pipefail

# Adjust for V1 or when V2 becomes stable.

RAYCAST_PROCESS_NAME="Raycast Beta"
RAYCAST_APPLICATION_PATH="/Applications/Raycast Beta.app"

open -g -a "$RAYCAST_APPLICATION_PATH"

/usr/bin/osascript -l JavaScript >/dev/null <<EOF
ObjC.import("AppKit")

const systemEvents = Application("System Events")

const applicationName = "${RAYCAST_PROCESS_NAME}"

if (!systemEvents.processes.byName(applicationName).exists()) throw new Error("Raycast is not running.")

const raycastProcess = systemEvents.processes.byName(applicationName)

for (let i = 0; i < 100 && raycastProcess.windows.length === 0; i++) delay(0.01)
if (raycastProcess.windows.length === 0) throw new Error("Raycast window not found.")

const firstWindow = raycastProcess.windows[0]
const firstWindowSize = firstWindow.size()

const mainScreen = $.NSScreen.mainScreen
const mainScreenFrame = mainScreen.frame
const mainScreenVisibleFrame = mainScreen.visibleFrame

const menuBar = mainScreenFrame.size.height - mainScreenVisibleFrame.size.height

const centerX = Math.round((mainScreenFrame.size.width - firstWindowSize[0]) / 2)
const centerY = Math.round(menuBar + (mainScreenVisibleFrame.size.height - firstWindowSize[1]) / 2)

firstWindow.position = [centerX, centerY]
EOF
