#!/usr/bin/env zsh
source ~/dotfiles/zsh/alex/functions.zsh

ZSH=${ZSH:-~/.oh-my-zsh}

setup_color

running "Now that it's done, source everything and install Homebrew"
source "$HOME/.zshrc"

if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
ok

source "$HOME/.zshrc"

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

"$(brew --prefix)/opt/fzf/install"  # fzf installation
ok

running "Installing Python"
curl https://bootstrap.pypa.io/get-pip.py -o "$HOME/Downloads/get-pip.py"
python3 "$HOME/Downloads/get-pip.py" --user
ok

running "Fixing fonts"
sudo chmod 775 ~/Library/Fonts/**/
ok
