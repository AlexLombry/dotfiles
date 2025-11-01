#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
cd $DOTFILES_DIR

echo "🚀 Copy or replace Stow Local Ignore file"
cp $DOTFILES_DIR/stow-local-ignore $HOME/.stow-local-ignore

echo "🚀 Loading ZSH Functions"
source ~/dotfiles/.oh-my-zsh/custom/alex/functions.zsh

setup_color

running "Install Oh My ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ok

running "Now that it's done, source everything and install Homebrew"
if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
ok

echo "🚀 Running Stow with --adopt flag"
stow . --adopt

source "$HOME/.zshrc"

running "Install mise (mise en place) for language/tool management"
HOMEBREW_NO_AUTO_UPDATE=1 brew install mise
ok

mise install
mise use -g

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
ok

"$(brew --prefix)/opt/fzf/install"  # fzf installation
ok

# Removed: Homebrew Python installation (now managed by mise)

running "Fixing fonts"
sudo chmod 775 ~/Library/Fonts/**/
ok
