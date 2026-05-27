#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Customer Orders Payload
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }

# Documentation:
# @raycast.author Alex Lombry

echo "$(curl -s "https://api.manomano.tech/api/v2/customer-orders/$1")"
