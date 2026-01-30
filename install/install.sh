#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
cd $DOTFILES_DIR

echo "🚀 Copy or replace Stow Local Ignore file"
cp $DOTFILES_DIR/stow-local-ignore $HOME/.stow-local-ignore

echo "🚀 Loading ZSH Functions"
source ~/dotfiles/.oh-my-zsh/custom/alex/functions.zsh

setup_color

# Check if zsh is our shell
if [[ "$SHELL" != *zsh ]]; then
  running "Switching to zsh"
  chsh -s $(which zsh)
  ok
fi

running "Install Oh My ZSH"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ok

running "Now that it's done, install Homebrew, Mise and Go Task"
if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
HOMEBREW_NO_AUTO_UPDATE=1 brew install mise go-task stow
ok

running "Running Complete Setup with Go Task"
task setup
ok

"$(brew --prefix)/opt/fzf/install" --all  # fzf installation
ok

# Removed: Homebrew Python installation (now managed by mise)

running "Fixing fonts"
sudo chmod 775 ~/Library/Fonts/**/
ok
