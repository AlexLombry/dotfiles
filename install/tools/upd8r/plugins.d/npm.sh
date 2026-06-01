#!/usr/bin/env bash
set -euo pipefail

# Load nvm from Homebrew opt path, fallback to ~/.nvm
NVM_BREW_DIR="$(brew --prefix 2>/dev/null)/opt/nvm"
if [[ -s "${NVM_BREW_DIR}/nvm.sh" ]]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  # shellcheck source=/dev/null
  source "${NVM_BREW_DIR}/nvm.sh"
elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "📦 -- npm: not found (nvm not loaded or npm not installed)"
  echo ""
  exit 0
fi

echo "📦 -- npm global packages"
echo "   npm version: $(npm --version)"

# npm outdated exits 1 when packages are outdated — suppress to avoid aborting set -e
outdated_before=$(npm outdated -g --parseable 2>/dev/null || true)

npm update -g

if [[ -n "$outdated_before" ]]; then
  echo "   Updated packages:"
  echo "$outdated_before" | awk -F: '{print "   •", $5}' | sort -u
else
  echo "   All global packages are up to date."
fi

echo ""
