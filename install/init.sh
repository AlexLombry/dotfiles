#!/usr/bin/env zsh
set -euo pipefail

echo "🚀 Setting up your Command Line Tools"

chsh -s '/bin/zsh'

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

if [ ! -d "$HOME/dotfiles" ]; then
    echo "🚀 Cloning Dotfiles from GitHub"
    git clone https://github.com/AlexLombry/dotfiles.git $HOME/dotfiles
fi

cd $HOME/dotfiles
exec ./install/install.sh
