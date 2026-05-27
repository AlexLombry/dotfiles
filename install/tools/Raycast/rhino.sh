#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rhino Discovery Endpoint
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔐
# @raycast.argument1 { "type": "text", "placeholder": "productId" }
# @raycast.argument2 { "type": "text", "placeholder": "isPro" }
# @raycast.argument3 { "type": "text", "placeholder": "plaftorm" }

# Documentation:
# @raycast.description Get specific key on vault
# @raycast.author Alex Lombry

if [ "$2" = "true" ]; then
  isPro=true
else
  isPro=false
fi

curl --silent --location "https://browserapi.manomano.com/api/v2/product-discovery/products/$1?is_pro=$isPro" --header "x-platform: $3" | jq
