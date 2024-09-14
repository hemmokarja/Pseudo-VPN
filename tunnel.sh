#!/bin/bash

IP_FILE=".config/instance_ip"
PRIVATE_KEY_PATH=".ssh/pseudo-vpn-key"

# read ip file
INSTANCE_IP=$(cat "$IP_FILE")
if [ -z "$INSTANCE_IP" ]; then
  echo "Failed to read IP address from '$IP_FILE'. Exiting."
  exit 1
fi

ssh-keyscan -H $INSTANCE_IP >> ~/.ssh/known_hosts 2>/dev/null

echo "SSH tunnel opened!"
ssh -i "$PRIVATE_KEY_PATH" -D 8080 -N ubuntu@"$INSTANCE_IP"

echo "SSH tunnel closed."
