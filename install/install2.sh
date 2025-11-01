#!/usr/bin/env bash
set -e

echo "🚀 Setting up your Mac..."

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install packages
if [ -f Brewfile ]; then
  echo "📦 Installing Brew packages..."
  brew bundle --file=Brewfile
fi

# Install GNU stow
brew install stow

# Symlink dotfiles
echo "🔗 Creating symlinks..."
stow zsh git nvim

# macOS settings (optional)
if [ -f macos_defaults.sh ]; then
  echo "⚙️ Applying macOS defaults..."
  ./macos_defaults.sh
fi

echo "✅ Setup complete! Restart your terminal."
