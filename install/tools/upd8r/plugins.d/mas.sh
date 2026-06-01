#!/usr/bin/env bash
set -euo pipefail

bold="\033[1m"
italic="\033[3m"
reset="\033[0m"

echo -e "${bold}🍏  Mac App Store updates${reset}"

command -v mas >/dev/null 2>&1 || {
  echo -e "  ${italic}mas${reset} is not installed. Run: brew install mas"
  exit 1
}

outdated=$(mas outdated 2>/dev/null || true)

if [[ -z "$outdated" ]]; then
  echo "   No App Store updates available."
  echo ""
  exit 0
fi

echo "   Updating App Store apps..."
mas upgrade
echo "   Done."
echo ""
