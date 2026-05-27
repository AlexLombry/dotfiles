#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Fetch Order from OneStock
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "int | stg | prd" }
# @raycast.argument2 { "type": "text", "placeholder": "OMS_ID" }

# Documentation:
# @raycast.author Alex Lombry
id=$2

# Checking the current environment
if [[ "$1" == "prd" ]]; then
    onestock_url="https://api.onestock-retail.com"
    onestock_password=$(security find-generic-password -w -a ${USER} -D "environment variable" -s "ONESTOCK_PRD_PASSWORD")
elif [[ "$1" == "stg" ]]; then
    onestock_url="https://api-training.onestock-retail.com"
    onestock_password=$(security find-generic-password -w -a ${USER} -D "environment variable" -s "ONESTOCK_STG_PASSWORD")
elif [[ "$1" == "int" ]]; then
    onestock_url="https://api-qualif.onestock-retail.com"
    onestock_password=$(security find-generic-password -w -a ${USER} -D "environment variable" -s "ONESTOCK_INT_PASSWORD")
else
    echo "Invalid environment"
    exit 1
fi

# Fetch current token from OneStock
token=$(curl -s --location "${onestock_url}/login" \
--header 'Content-Type: application/json' \
--data '{
    "site_id": "c680",
    "user_id": "manomano",
    "password": "'$onestock_password'"
}' | jq -r '.token')

if [[ -z "$token" ]]; then
    echo "Error: onestock_token is empty"
    exit;
fi

call=$(curl -s --location --request GET "${onestock_url}/v2/orders/${id}" \
--header 'Content-Type: application/json' \
--data '{
    "site_id": "c680",
    "token": "'$token'",
    "fields": [
    "id",
    "types",
    "date",
    "last_update",
    "sales_channel",
    "state",
    "information",
    "original_ruleset_id",
    "original_ruleset_chaining_id",
    "ruleset_id",
    "expiration_dates",
    "customer",
    "delivery.type",
    "delivery.destination.address",
    "delivery.destination.endpoint_id",
    "pricing_details",
    "order_items._id",
    "order_items.item_id",
    "order_items.quantity",
    "order_items.pricing_details",
    "order_items.information",
    "ordering.endpoint_id",
    "ordering.user_id",
    "reservation_rank",
    "shipping_fees",
    "parcels.id",
    "parcels.order_id",
    "parcels.state",
    "parcels.line_item_indexes",
    "parcels.information",
    "parcels.delivery.destination.address",
    "parcels.delivery.destination.endpoint_id",
    "parcels.delivery.origin",
    "parcels.delivery.carrier",
    "parcels.delivery.type",
    "parcels.shipment.tracking_code",
    "line_item_groups.order_id",
    "line_item_groups.order_item_id",
    "line_item_groups.item_id",
    "line_item_groups.endpoint_id",
    "line_item_groups.quantity",
    "line_item_groups.parcel_id",
    "line_item_groups.reason",
    "line_item_groups.epcs",
    "line_item_groups.last_update",
    "line_item_groups.state",
    "line_item_groups.index_ranges",
    "delivery_promise.original_delivery_option",
    "sent_delivery_option",
    "current_delivery_etas"
  ]
}');

echo $call | jq;
