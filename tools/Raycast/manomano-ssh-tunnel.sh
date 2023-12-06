#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ManoMano SSH Tunnel
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Launch a Tunnel for multiple environment
# @raycast.author Alex Lombry
# @raycast.argument1 { "type": "text", "placeholder": "create | close" }
# @raycast.argument2 { "type": "text", "placeholder": "int | stg | prd | all", "optional": true }

# if argument1 dont exist
if [[ "$1" != "create" && "$1" != "close" ]]; then
    # Code that should run when args1 is not create or close
    echo "Wrong parameters" 
    exit 1
fi

ssh-tunnel -a $1 -e $2 -u "alex.lombry"
