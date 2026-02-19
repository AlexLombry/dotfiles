#!/bin/bash

# Print the logo
print_logo() {
    cat << "EOF"
    ______                _ __    __
   / ____/______  _______(_) /_  / /__
  / /   / ___/ / / / ___/ / __ \/ / _ \
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  macOS System Crafting Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: AlexLombry (cp: typescraft)

EOF
}

# Parse command line arguments
DEV_ONLY=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --dev-only) DEV_ONLY=true; shift ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

# Update the system first

echo "Updating system..."
if ! xcode-select -p &> /dev/null; then
    echo "🚀 Install mandatory XCode Developer Tools and Signing licence"
    xcode-select --install &> /dev/null
    # Wait until the Xcode Command Line Tools are installed
    while ! xcode-select -p &> /dev/null; do
        sleep 5
    done
    # After successful installation, prompt user to agree to the license.
    sudo xcodebuild -license
fi

if [ ! -d "$HOME/dotfiles" ]; then
    echo "🚀 Cloning Dotfiles from GitHub"
    git clone https://github.com/AlexLombry/dotfiles.git $HOME/dotfiles
fi

echo "Please launch the following command in a new terminal"
echo "cd $HOME/dotfiles"
echo "./install/install.sh"

exit 0
