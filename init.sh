#!/usr/bin/env zsh
git clone https://github.com/AlexLombry/dotfiles.git ~/dotfiles
cd ~/dotfiles

# First of all install Xcode Command Line Tools
running "XCode Command Line Tools"
if ! xcode-select -p &> /dev/null; then
    xcode-select --install &> /dev/null
    # Wait until the Xcode Command Line Tools are installed
    while ! xcode-select -p &> /dev/null; do
        sleep 5
    done
    # After successful installation, prompt user to agree to the license.
    sudo xcodebuild -license
fi
ok

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

zsh install.sh
