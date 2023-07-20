#!/usr/bin/env zsh
source ~/dotfiles/zsh/alex/functions.zsh

ZSH=${ZSH:-~/.oh-my-zsh}

setup_color

# First of all install xcode developer tool, without it nothing works properly
running "XCode Command Line Tools"
if [ $(xcode-select -p &> /dev/null; printf $?) -ne 0 ]; then
    xcode-select --install &> /dev/null
    # Wait until the XCode Command Line Tools are installed
    while [ $(xcode-select -p &> /dev/null; printf $?) -ne 0 ]; do
        sleep 5
    done
    xcode-select -p &> /dev/null
    if [ $? -eq 0 ]; then
        # Prompt user to agree to the terms of the Xcode license
        # https://github.com/alrra/dotfiles/issues/10
       sudo xcodebuild -license
   fi
fi
ok

running "Now that it's done, source everything and install Homebrew"
source $HOME/.zshrc

if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
ok

source $HOME/.zshrc

running "Now we install Go Task to be able to run task builder"
HOMEBREW_NO_AUTO_UPDATE=1 brew install go-task/tap/go-task
ok

running "Ok, now we can install our brew bundle entirely"
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle
ok

running "Installation of AWS SDK v2 needed for work"
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm -rf AWSCLIV2.pkg
ok

running "Running GO Task installation tools for macOS, OMZ ..."
task "os"
task "zsh"
task "links"
ok

$(brew --prefix)/opt/fzf/install
ok

running "Installing Python"
curl https://bootstrap.pypa.io/get-pip.py -o "$HOME/Downloads/get-pip.py"
python3 "$HOME/Downloads/get-pip.py" --user
ok

running "Fixing fonts"
sudo chmod 775 ~/Library/Fonts/**/
ok
