#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ManoMano SSH Tunnel
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 👨‍💻

# Documentation:
# @raycast.description Launch a Tunnel for multiple environment
# @raycast.author Alex Lombry

# if argument1 dont exist
# if [[ "$1" != "create" && "$1" != "close" ]]; then
#     # Code that should run when args1 is not create or close
#     echo "Wrong parameters" 
#     exit 1
# fi

$HOME/.local/bin/ssh-tunnel -a create -e all