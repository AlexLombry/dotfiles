#!/usr/bin/env bash

UPD8R_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_BIN="$(brew --prefix)/bin"

# Make Upd8r accessible in PATH
sudo ln -fs "${UPD8R_PATH}/upd8r.sh" "${BREW_BIN}/upd8r"

echo "✅ Upd8R has been installed !"
