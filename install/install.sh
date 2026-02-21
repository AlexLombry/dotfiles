#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
cd $DOTFILES_DIR

echo "🚀 Copy or replace Stow Local Ignore file"
cp $DOTFILES_DIR/stow-local-ignore $HOME/.stow-local-ignore

echo "🚀 Loading ZSH Functions"

# Check if zsh is our shell
if [[ "$SHELL" != *zsh ]]; then
  echo "✅ Switching to zsh"
  chsh -s $(which zsh)
fi

echo "Install Oh My ZSH"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "✅ Now that it's done, install Homebrew, Mise and Go Task"
if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for the current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

if ! command_exists brew; then
  echo "🔴 Homebrew not found. Please install it manually."
  exit 1
fi

HOMEBREW_NO_AUTO_UPDATE=1 brew install mise go-task stow
# Ensure task is available in PATH (installed by brew)
if ! command_exists task; then
    if [[ -f /opt/homebrew/bin/task ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -f /usr/local/bin/task ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi
fi

echo "🚀 Running Complete Setup with Go Task"
task setup

"$(brew --prefix)/opt/fzf/install" --all  # fzf installation

# Removed: Homebrew Python installation (now managed by mise)

echo "⚙️ Fixing fonts"
sudo chmod 775 ~/Library/Fonts/**/
