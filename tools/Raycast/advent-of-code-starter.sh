#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Advent Of Code Starter
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Alex Lombry

if [ $(date +%m) != 12 ]; then
  echo "It's not December yet"
  exit 1
fi

cd $HOME/Code/AdventOfCode
./day.sh

echo "Have fun for this AdventOfCode session"

