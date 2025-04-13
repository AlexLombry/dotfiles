#!/usr/bin/env zsh
echo "First we need to install the Command Line Tools"
echo "After that, we will install ohMyZsh and change our current Bash to zsh"

# First of all install Xcode Command Line Tools
echo "XCode Command Line Tools"
if ! xcode-select -p &> /dev/null; then
    xcode-select --install &> /dev/null
    # Wait until the Xcode Command Line Tools are installed
    while ! xcode-select -p &> /dev/null; do
        sleep 5
    done
    # After successful installation, prompt user to agree to the license.
    sudo xcodebuild -license
fi

chsh -s '/bin/zsh'

git clone https://github.com/AlexLombry/dotfiles.git ~/dotfiles
cd ~/dotfiles

zsh install.sh
