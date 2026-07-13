#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Resize Window for App Store Screenshot
# @raycast.description Resize the frontmost app window so a Retina screenshot is exactly 2880x1800px (App Store 13" size).
# @raycast.mode silent
# @raycast.packageName Screenshots
# @raycast.icon 📐
# @raycast.argument1 { "type": "text", "placeholder": "2880x1800", "optional": true }

set -euo pipefail

# Target size in PIXELS. Override via argument, e.g. "2560x1600".
TARGET="${1:-2880x1800}"
PX_W="${TARGET%x*}"
PX_H="${TARGET#*x}"

/usr/bin/osascript -l JavaScript >/dev/null <<EOF
ObjC.import("AppKit")

const pxW = ${PX_W}
const pxH = ${PX_H}

const systemEvents = Application("System Events")
const front = systemEvents.processes.whose({ frontmost: true })[0]
if (!front) throw new Error("No frontmost application.")

for (let i = 0; i < 100 && front.windows.length === 0; i++) delay(0.01)
if (front.windows.length === 0) throw new Error("Frontmost app has no window.")

const win = front.windows[0]

// AppleScript sizes windows in POINTS; screenshots capture in PIXELS.
// pixels = points * backingScaleFactor, so points = pixels / scale.
const screens = $.NSScreen.screens
let scale = $.NSScreen.mainScreen.backingScaleFactor
let visible = $.NSScreen.mainScreen.visibleFrame

// Pick the screen the window currently sits on (multi-monitor safe).
const pos = win.position()
for (let i = 0; i < screens.count; i++) {
  const s = screens.objectAtIndex(i)
  const f = s.frame
  if (pos[0] >= f.origin.x && pos[0] < f.origin.x + f.size.width) {
    scale = s.backingScaleFactor
    visible = s.visibleFrame
    break
  }
}

const w = Math.round(pxW / scale)
const h = Math.round(pxH / scale)

// Move to the screen's top-left visible corner so the whole window fits,
// then size it. Cocoa Y is bottom-up; System Events Y is top-down.
win.position = [Math.round(visible.origin.x), 25]
win.size = [w, h]
EOF
