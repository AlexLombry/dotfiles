#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vault PRD MS
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔐
# @raycast.argument1 { "type": "text", "placeholder": "int/stg/prd" }
# @raycast.argument2 { "type": "text", "placeholder": "service name" }
# @raycast.argument3 { "type": "text", "placeholder": "appli/web" }

# Documentation:
# @raycast.description Get specific key on vault
# @raycast.author Alex Lombry

export VAULT_ADDR=https://vault-eu-west-3.$1.manomano.com
vault login -path=sso -method=oidc role=order
vault kv get -field=data -format=json $1/ms/$2/$3 | jq | pbcopy