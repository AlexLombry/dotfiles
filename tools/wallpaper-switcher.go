package main

import (
	"fmt"
	"os/exec"
	"time"
)

// adjust these paths and times as you wish:
const (
	dayWallpaper   = "/Users/alex/Library/CloudStorage/Dropbox/Images/AlexWall/it-hack/cyber1_upscayl_2x_digital-art-4x.png"
	nightWallpaper = "/Users/alex/Library/CloudStorage/Dropbox/Images/AlexWall/code/vim-1.png"
	// switch times in 24 h format
	dayStartHour     = 19
	dayStartMinute   = 17
	nightStartHour   = 19
	nightStartMinute = 19
)

// setWallpaper uses AppleScript via osascript to set the desktop picture.
func setWallpaper(path string) error {
	script := fmt.Sprintf(
		`tell application "Finder" to set desktop picture to POSIX file "%s"`,
		path,
	)
	cmd := exec.Command("osascript", "-e", script)
	return cmd.Run()
}

// minutesSinceMidnight returns the total minutes elapsed since 00:00.
func minutesSinceMidnight(t time.Time) int {
	return t.Hour()*60 + t.Minute()
}

func main() {
	// compute switch points
	dayStart := dayStartHour*60 + dayStartMinute
	nightStart := nightStartHour*60 + nightStartMinute

	last := ""
	for {
		now := time.Now()
		mm := minutesSinceMidnight(now)

		var target string
		// normal interval: dayStart → nightStart
		if dayStart <= nightStart {
			if mm >= dayStart && mm < nightStart {
				target = dayWallpaper
			} else {
				target = nightWallpaper
			}
		} else {
			// wrap-around (e.g. day at 20:00, night at 06:00)
			if mm >= dayStart || mm < nightStart {
				target = dayWallpaper
			} else {
				target = nightWallpaper
			}
		}

		if target != last {
			if err := setWallpaper(target); err != nil {
				fmt.Printf("failed to set wallpaper: %v\n", err)
			} else {
				fmt.Printf("[%s] switched to %s\n", now.Format("15:04"), target)
				last = target
			}
		}

		// sleep until the start of the next minute
		time.Sleep(time.Until(now.Truncate(time.Minute).Add(time.Minute)))
	}
}
