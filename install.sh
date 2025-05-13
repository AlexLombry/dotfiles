#!/usr/bin/env zsh
set -euo pipefail

source ~/dotfiles/zsh/alex/functions.zsh

setup_color

running "Now that it's done, source everything and install Homebrew"

if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
ok

source "$HOME/.zshrc"

running "Now we install Go Task to be able to run task builder"
HOMEBREW_NO_AUTO_UPDATE=1 brew install go-task/tap/go-task
ok

# running "Ok, now we can install our brew bundle entirely"
# HOMEBREW_NO_AUTO_UPDATE=1 brew bundle
# ok

running "Installation of AWS SDK v2 needed for work"
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm -rf AWSCLIV2.pkg
ok

running "Running GO Task installation tools for macOS, OMZ ..."
task "os"
task "neovim"
task "zsh"
task "links"
ok

"$(brew --prefix)/opt/fzf/install"  # fzf installation
ok

running "Installing Python via Homebrew"
HOMEBREW_NO_AUTO_UPDATE=1 brew install python
ok

running "Fixing fonts"
sudo chmod 775 ~/Library/Fonts/**/
ok
