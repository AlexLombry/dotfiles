#!/usr/bin/env bash
xcode-select --install
source $HOME/.zshrc
sudo xcodebuild -license accept
git clone https://github.com/AlexLombry/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
