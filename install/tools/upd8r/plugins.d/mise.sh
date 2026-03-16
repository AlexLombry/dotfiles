#!/usr/bin/env bash
if hash mise 2>/dev/null; then
  echo "⚙️ -- mise"
  mise self-update

  echo ""

  echo "🌬 -- Upgrading mise"
  mise upgrade
fi
