#!/usr/bin/env bash
set -euo pipefail

cat <<'BANNER'

░██     ░██                   ░██  ░██████  ░█████████
░██     ░██                   ░██ ░██   ░██ ░██     ░██
░██     ░██ ░████████   ░████████ ░██   ░██ ░██     ░██
░██     ░██ ░██    ░██ ░██    ░██  ░██████  ░█████████
░██     ░██ ░██    ░██ ░██    ░██ ░██   ░██ ░██   ░██
 ░██   ░██  ░███   ░██ ░██   ░███ ░██   ░██ ░██    ░██
  ░██████   ░██░█████   ░█████░██  ░██████  ░██     ░██
            ░██
            ░██

BANNER

echo "🚀 Running Upd8R to keep your working environment up to date!"

MAX_WIDTH=50
CURRENT_WIDTH="$(tput cols 2>/dev/null || echo 80)"
COLUMNS=$(( CURRENT_WIDTH > MAX_WIDTH ? MAX_WIDTH : CURRENT_WIDTH ))
printf '%*s\n' "${COLUMNS}" '' | tr ' ' =

SCRIPTS_DIR="$HOME/dotfiles/install/tools/upd8r/plugins.d"

if [[ -d "$SCRIPTS_DIR" ]]; then
  shopt -s nullglob
  for script in "$SCRIPTS_DIR"/*; do
    if [[ -f "$script" && -x "$script" ]]; then
      "$script" "$@"
    fi
  done
else
  echo "Warning: plugins directory not found: $SCRIPTS_DIR" >&2
fi
