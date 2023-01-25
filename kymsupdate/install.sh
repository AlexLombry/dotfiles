#!/usr/bin/env bash

KYMSU_PATH="$HOME/dotfiles/kymsupdate"

# Make Kymsu accessible in PATH
sudo ln -fs "${KYMSU_PATH}"/kymsu.sh /usr/local/bin/kymsu

echo "KYMSU has been installed. Run kymsu command!"
