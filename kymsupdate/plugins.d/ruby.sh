#!/usr/bin/env bash
if hash gem 2>/dev/null; then
    echo "💎 -- Upgrading ruby itself"
    sudo gem update --system
    sudo gem update
    sudo gem cleanup
    echo ""
fi