#!/usr/bin/env bash
# Source UI helpers (try symlinked path first, then local repo path)
if [[ -f "$HOME/.oh-my-zsh/custom/alex/ui.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/alex/ui.zsh"
else
    source "$(dirname "$0")/../stow/zsh/.oh-my-zsh/custom/alex/ui.zsh"
fi

running "Close any open System Preferences panes, to prevent them from overriding"
bot "settings we’re about to change"
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
bot "I need you to enter your sudo password so I can apply macOS defaults:"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `macos.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

running "Allow any Application to be installed"
sudo spctl --master-disable

running "not showing hidden files by default"
set_default com.apple.Finder AppleShowAllFiles false

running "Schedule update once a day"
set_default com.apple.SoftwareUpdate ScheduleFrequency 1 -int

running "Disable smart quotes and dashes"
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled false
set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled false

running "Correct spelling automatically"
set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled false

running "only use UTF-8 in Terminal.app"
set_default com.apple.terminal StringEncodings 4 -array

running "Expand save dialog by default"
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode true

running "Show the ~/Library folder in Finder"
chflags nohidden ~/Library

running "Stop that DSStore file nightmare"
set_default com.apple.desktopservices DSDontWriteNetworkStores true

running "Use current directory as default search scope in Finder"
set_default com.apple.finder FXDefaultSearchScope "SCcf" -string

running "Enable autohide for the Dock"
set_default com.apple.dock autohide true

running "Set a blazingly fast keyboard repeat rate"
set_default NSGlobalDomain KeyRepeat 2 -int

running "Set keyboard no press and hold"
set_default -g ApplePressAndHoldEnabled false

running "Set a shorter Delay until key repeat"
set_default NSGlobalDomain InitialKeyRepeat 15 -int

running "Increase sound quality for Bluetooth headphones/headsets"
set_default com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 40 -int

running "Enable tap to click (Trackpad)"
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking true

running "Enable Safari's debug menu"
set_default com.apple.Safari IncludeInternalDebugMenu true

running "Disable smart quotes in Messages"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

running "Disable natural scrolling"
set_default NSGlobalDomain com.apple.swipescrolldirection false

running "Speed up Dock switching"
set_default com.apple.dock "autohide-delay" 0 -float
set_default com.apple.dock "autohide-time-modifier" 0 -float
killall Dock

running "Automatically open a new Finder window when a volume is mounted"
set_default com.apple.frameworks.diskimages auto-open-ro-root true
set_default com.apple.frameworks.diskimages auto-open-rw-root true
set_default com.apple.finder OpenWindowForNewRemovableDisk true

# ==============================================
# Finder
# ==============================================
bot "Setting Finder preferences"

running "Expand the Open with and Sharing & Permissions panes"
defaults write com.apple.finder FXInfoPanesExpanded -dict OpenWith -bool true Privileges -bool true

running "Show status bar"
set_default com.apple.finder ShowStatusBar true

running "New window points to home"
set_default com.apple.finder NewWindowTarget "PfHm" -string

running "Finder: disable window animations"
set_default com.apple.finder DisableAllAnimations true

running "Show icons for servers and removable media on the desktop"
set_default com.apple.finder ShowExternalHardDrivesOnDesktop true
set_default com.apple.finder ShowHardDrivesOnDesktop false
set_default com.apple.finder ShowMountedServersOnDesktop true
set_default com.apple.finder ShowRemovableMediaOnDesktop true

running "Show Path bar in Finder"
set_default com.apple.finder ShowPathbar true

running "Finder: show all filename extensions"
set_default NSGlobalDomain AppleShowAllExtensions true

running "Finder: allow text selection in Quick Look"
set_default com.apple.finder QLEnableTextSelection true

running "Use list view"
set_default com.apple.finder FXPreferredViewStyle "Nlsv" -string

###############################################################################
# Screen                                                                      #
###############################################################################
running "Save screenshots to the desktop (or Dropbox if it exists)"
SCREENSHOTS_DIR="${HOME}/Dropbox/Screenshots"
if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
    SCREENSHOTS_DIR="${HOME}/Desktop"
fi
set_default com.apple.screencapture location "$SCREENSHOTS_DIR" -string

running "Save screenshots in PNG format"
set_default com.apple.screencapture type "png" -string

running "Disable shadow in screenshots"
set_default com.apple.screencapture disable-shadow true

running "Show full file path in Finder title"
set_default com.apple.finder _FXShowPosixPathInTitle true

running "Show expanded state for printing"
set_default -g PMPrintingExpandedStateForPrint true

running "Privacy: don’t send search queries to Apple"
set_default com.apple.Safari UniversalSearchEnabled false
set_default com.apple.Safari SuppressSearchSuggestions true

running "Set Safari’s home page to about:blank"
set_default com.apple.Safari HomePage "about:blank" -string

running "Prevent Safari from opening ‘safe’ files automatically"
set_default com.apple.Safari AutoOpenSafeDownloads false

running "Copy email addresses as foo@example.com in Mail.app"
set_default com.apple.mail AddressesIncludeNameOnPasteboard false

running "Display emails in threaded mode, sorted by date"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

running "Disable automatic spell checking in Mail"
set_default com.apple.mail SpellCheckingBehavior "NoSpellCheckingEnabled" -string

running "Prevent Time Machine from prompting to use new hard drives"
set_default com.apple.TimeMachine DoNotOfferNewDisksForBackup true

running "Disable apple sound beep feedback"
set_default "com.apple.sound.beep.feedback" 1 -int

running "7 days for Calendar"
set_default com.apple.iCal "n days of week" 7 -int

bot "Done! Note that some of these changes require a logout/restart to take effect."
