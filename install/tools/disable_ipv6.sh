#!/bin/bash
# This script sets IPv6 to Link‑Local Only only on network interfaces that are currently active
# (i.e. have an assigned IPv4 address, indicating they are used for Internet connectivity)

# Get the list of network services (skip the header line)
services=$(networksetup -listallnetworkservices | tail +2)

# Function to check if a network service has a valid IP address
has_ip() {
    local svc="$1"
    # Get the IP address information for the service
    ip_info=$(networksetup -getinfo "$svc")
    # Look for a valid IP address line that isn't "none"
    if echo "$ip_info" | grep -q "IP address: [^none]"; then
        return 0
    else
        return 1
    fi
}

# Loop through each service
while IFS= read -r svc; do
    if has_ip "$svc"; then
        echo "Configuring IPv6 to Link-Local Only for active interface: $svc"
        sudo networksetup -setv6LinkLocal "$svc"
    else
        echo "Skipping inactive interface: $svc"
    fi
done <<< "$services"

echo "IPv6 has been set to Link‑Local Only for active network interfaces."