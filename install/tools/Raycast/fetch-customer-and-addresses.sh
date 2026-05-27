#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Fetch Customer and addresses
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Customer ID" }
# @raycast.argument2 { "type": "text", "placeholder": "Platform", "optional": true }

# Documentation:
# @raycast.author Alex Lombry

platform=$(echo "$2" | tr '[:lower:]' '[:upper:]')
first=$(curl -s "https://api.manomano.tech/api/v2/customers/$1" | jq)

echo $first

if [[ "$2" != "" ]]; then
    # Code that should run when args1 is not create or close
    second=$(curl -s "https://api.manomano.tech/api/v2/customers/addresses?customer_id=$1&platform_id=$platform" | jq)
    echo $second
fi
