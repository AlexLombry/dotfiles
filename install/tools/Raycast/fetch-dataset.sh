#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Fetch Dataset
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔗
# @raycast.argument1 { "type": "text", "placeholder": "int/stg" }
# @raycast.argument2 { "type": "text", "placeholder": "Dataset ID (UUID)" }
# @raycast.description Fetch a dataset by ID from the ManoMano datasets builder API (staging)

PLATFORM="$1"
DATASET_ID="$2"

if [ -z "$DATASET_ID" ]; then
  echo "Error: Dataset ID is required"
  exit 1
fi
if [ -z "$PLATFORM" ]; then
  echo "Error: Plaform should be int or stg"
  exit 1
fi

RESPONSE=$(curl --silent --location "https://ms-datasets-builder-api.ingress.eu-west-3.${PLATFORM}.manomano.com/api/v1/datasets/${DATASET_ID}" | jq)

echo "$RESPONSE" | pbcopy
echo "$RESPONSE"
