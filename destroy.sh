#!/bin/bash

KEY_NAME="pseudo-vpn-key"
KEY_DIR=".ssh"
PRIVATE_KEY_PATH="$KEY_DIR/$KEY_NAME"
PUBLIC_KEY_PATH="$PRIVATE_KEY_PATH.pub"
CONFIG_DIR=".config"
REGION_FILE_PATH="$CONFIG_DIR/region"
DUMMY_IP="0.0.0.0/32"


if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set as environment" \
    "variables! Exiting." >&2
  exit 1
fi


# read region file
if [ -f "$REGION_FILE_PATH" ]; then
  REGION=$(cat "$REGION_FILE_PATH")
else
  echo "Region file '$REGION_FILE_PATH' not found. Exiting."
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Failed to read region from '$REGION'. Exiting."
  exit 1
fi


# destroy resources
echo "Destroying Terraform resources (this might take a while)..."
terraform destroy \
  -var "key_pair_name=$KEY_NAME" \
  -var "public_key_path=$PUBLIC_KEY_PATH" \
  -var "allowed_ip=$DUMMY_IP" \
  -var "region=$REGION" \
  -auto-approve


# delete keys and configs
if [ -d "$CONFIG_DIR" ]; then
  rm -rf "$CONFIG_DIR"
  echo "Terraform configs deleted."
fi

if [ -d "$KEY_DIR" ]; then
  rm -rf "$KEY_DIR"
  echo "SSH keys deleted."
fi

echo "All resources cleaned up!"
