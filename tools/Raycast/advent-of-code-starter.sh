#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Advent Of Code Starter
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Alex Lombry

FOLDER=$HOME/Code/AdventOfCode
DAY=$(date +'%d')
YEAR=$(date +%Y)

if [ $(date +%m) != 12 ]; then
  echo "It's not December yet"
  exit 1
fi

cd $HOME/Code/AdventOfCode
if [ -f $FOLDER/src/aoc$YEAR/Day$DAY.kt ]; then
  echo "$FOLDER/src/aoc$YEAR/Day$DAY.kt already exist"
  exit 1
fi

./day.sh

echo "Have fun for this AdventOfCode session"

