#!/usr/bin/env bash
source ~/dotfiles/zsh/functions.zsh

running "Close any open System Preferences panes, to prevent them from overriding"

bot "settings we’re about to change"
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
bot "I need you to enter your sudo password so I can install some things:"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

running "Allow any Application to be installed"
sudo spctl --master-disable

running "not showing hidden files by default"
defaults write com.apple.Finder AppleShowAllFiles -bool false

running "Schedule update once a day"
defaults write SoftwareUpdate ScheduleFrequency -int 1

running "Disable smart quotes and dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

running "Correct spelling automatically"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

running "only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

running "Expand save dialog by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

running "Show the ~/Library folder in Finder"
chflags nohidden ~/Library

running "Use current directory as default search scope in Finder"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

running "Enable autohide for the Dock"
defaults write com.apple.dock autohide -bool true

running "Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 0

running "Set a shorter Delay until key repeat"
defaults write NSGlobalDomain InitialKeyRepeat -int 0

running "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

running "Disable auto correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

running "Enable tap to click (Trackpad)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

running "Enable Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

running "Disable smart quotes as it's annoying for messages that contain code"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

running "Disable natural Lion-style scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

running "Speed up Dock switching"
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
killall Dock

running "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# ==============================================
# Finder
# ==============================================
bot "Setting Finder preferences"

running "Expand the Open with and Sharing & Permissions panes"
defaults write com.apple.finder FXInfoPanesExpanded -dict OpenWith -bool true Privileges -bool true

running "Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

running "New window points to home"
defaults write com.apple.finder NewWindowTarget -string "PfHm"

running "Finder: disable window animations and Get Info animations"
defaults write com.apple.finder DisableAllAnimations -bool true

running "Show icons for servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

running "Show Path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true

running "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

running "Finder: allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

running "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

running "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

running "Use list view"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

###############################################################################
# Screen                                                                      #
###############################################################################
running "Save screenshots to the desktop"
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

running "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png"

running "Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

running "Show full file path"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES

running "Show expanded state for printing"
defaults write -g PMPrintingExpandedStateForPrint -bool TRUE

bot "Please run command defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText \"LOCK MESSAGE\""

running "Privacy: don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

running "Set Safari’s home page to about:blank for faster loading"
defaults write com.apple.Safari HomePage -string "about:blank"

running "Prevent Safari from opening ‘safe’ files automatically after downloading"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

running "Copy email addresses as foo@example.com instead of Foo Bar <foo@example.com> in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

running "Display emails in threaded mode, sorted by date (oldest at the top)"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

running "Disable inline attachments (just show the icons)"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

running "Disable automatic spell checking"
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

running "Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

running "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

running "Disable apple sound beep feedback"
defaults write "com.apple.sound.beep.feedback" -int 1

running "7 days for Calendar"
defaults write com.apple.iCal n\ days\ of\ week 7

# running "Fix issue with Audio Bluetooth"

# defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" 80
# defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 80
# defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool (editable)" 80
# defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool Min (editable)" 80
# defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool" 80
# defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Max" 80
# defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Min" 80

# ==============================================
# Kill affected applications
# ==============================================

function killallApps() {
    killall "Finder" > /dev/null 2>&1
    killall "SystemUIServer" > /dev/null 2>&1
    killall "Dock" > /dev/null 2>&1

    appsToKill=(
    "Activity Monitor"
    "BBEdit"
    "Calendar"
    "Contacts"
    "Dashboard"
    "Disk Utility"
    "Safari"
    "System Preferences"
    "TextWrangler"
    "Xcode"
    )

    for app in "${appsToKill[@]}"
    do
        killall "${app}" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            # We just killed an app so restart it
            open -a "${app}"
        fi
    done

    bot "Note that some of these changes require a logout/restart to take effect."
}

printf "Restart the affected applications? (y/n): "
read killallReply
if [[ $killallReply =~ ^[Yy]$ ]]; then
    killallApps
fi
