#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title RHI Offer Catalog
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "ProductIds" }
# @raycast.argument2 { "type": "text", "placeholder": "Platform" }
# @raycast.argument3 { "type": "text", "placeholder": "MarketPlace" }

# Documentation:
# @raycast.description Rhino Offer Catalog
# @raycast.author Alex Lombry

curl --location "https://ms-rhino-reader-api.ingress.prd.manomano.com/api/offer-catalog/v1/offers?accept_non_sellable=true&product_ids=$1" \
--header "x-mm-platform: $2" \
--header "x-mm-market: $3" \
--header "x-mm-user-agent: postman-rhino/v0.0.0"
