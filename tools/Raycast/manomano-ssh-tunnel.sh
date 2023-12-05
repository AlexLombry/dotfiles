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
# @raycast.argument1 { "type": "text", "placeholder": "create" }
# @raycast.argument2 { "type": "text", "placeholder": "environment" }

ssh-tunnel -a $1 -e $2 -u "alex.lombry"
