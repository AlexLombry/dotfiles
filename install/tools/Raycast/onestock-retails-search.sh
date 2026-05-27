#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title OneStock Retails search
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔍
# @raycast.argument1 { "type": "text", "placeholder": "int | stg | prd" }
# @raycast.argument2 { "type": "text", "placeholder": "OMS ID" }

case $1 in
    "int") URL="https://admin-qualif.onestock-retail.com/c680/order/detail" ;;
    "stg") URL="https://admin-training.onestock-retail.com/c680/order/detail" ;;
    "prd") URL="https://admin.onestock-retail.com/c680/order/detail" ;;
        *) URL="https://admin.onestock-retail.com/c680/order/detail" ;;
esac

open "$URL/$2"

echo "Opening OneStock Order id $1"