#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System Full Update
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.description Update the entire macOS System
# @raycast.author Alex Lombry


echo "Update macOS"
sudo softwareupdate --all --install --force

echo "Update Homebrew"
brew update
brew upgrade
brew cleanup

echo "Update NPM"
npm install npm -g
npm update -g

echo "Update Gems"
sudo gem update --system
sudo gem update
sudo gem cleanup


