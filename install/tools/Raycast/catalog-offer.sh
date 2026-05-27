#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Catalog offer
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "int/stg/prd" }
# @raycast.argument2 { "type": "text", "placeholder": "ae92e5a6-a0ad-4f2b-a820-0075d8ec84d6" }

# Documentation:
# @raycast.author Alex Lombry

curl --silent --location 'https://ms-offer-reader-web.ingress.eu-west-3.'$1'.manomano.com/api/v2/catalog/offers/search?compatibility=legacy-id' \
--data '{
	"filters": [
		{"om_offer_id":"'$2'"}
	]
}' | jq
