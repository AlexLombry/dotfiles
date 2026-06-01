#!/usr/bin/env bash
set -euo pipefail

echo "🍎 -- macOS Software Updates"

# softwareupdate writes its listing to stderr; redirect for parsing
available=$(softwareupdate -l 2>&1)

if echo "$available" | grep -q "No new software available"; then
  echo "   macOS is up to date."
  echo ""
  exit 0
fi

updates=$(echo "$available" | grep '^\* Label:' | sed 's/^\* Label: //')

if [[ -z "$updates" ]]; then
  echo "   macOS is up to date."
  echo ""
  exit 0
fi

echo "   Available updates:"
while IFS= read -r update; do
  echo "   • $update"
done <<< "$updates"
echo ""

# Non-interactive (cron, pipe, CI): report only
if [[ ! -t 0 ]]; then
  echo "   Run 'sudo softwareupdate -ia' manually to install."
  echo ""
  exit 0
fi

printf "   Install updates now? This may require a restart. [y/N] "
read -r choice
case "$choice" in
  [Yy]*)
    echo "   Installing macOS updates..."
    sudo softwareupdate -ia
    echo "   Done. A restart may be required."
    ;;
  *)
    echo "   Skipped. Run 'sudo softwareupdate -ia' manually when ready."
    ;;
esac

echo ""
