#!/usr/bin/env bash
brew remove neovim
ln -s ~/dotfiles/nvim ~/.config/nvim

brew install luarocks luv
brew install --HEAD luajit
brew install --HEAD neovim
