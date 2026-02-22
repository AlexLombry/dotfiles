#!/usr/bin/env bash

UPD8R_PATH="$HOME/dotfiles/install/tools/upd8r"

# Make Upd8r accessible in PATH
sudo ln -fs "${UPD8R_PATH}"/upd8r.sh /usr/local/bin/upd8r

echo "✅ Upd8R has been installed !"
