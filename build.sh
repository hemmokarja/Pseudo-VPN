#!/bin/bash

KEY_NAME="pseudo-vpn-key"
KEY_DIR=".ssh"
PRIVATE_KEY_PATH="$KEY_DIR/$KEY_NAME"
PUBLIC_KEY_PATH="$PRIVATE_KEY_PATH.pub"
CONFIG_DIR=".config"
IP_FILE_PATH="$CONFIG_DIR/instance_ip"
REGION_FILE_PATH="$CONFIG_DIR/region"


if [ -z "$AWS_SECRET_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_KEY_ID and AWS_SECRET_ACCESS_KEY must be set as environment" \
    "variables! Exiting." >&2
  exit 1
fi


if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

if [ ! -d "$KEY_DIR" ]; then
  mkdir -p "$KEY_DIR"
fi


# select region and instance type
function get_aws_regions {
  aws ec2 describe-regions --query "Regions[].RegionName" --output text
}

function prompt_for_region {
  local default_region="us-east-1"
  local regions=$(get_aws_regions | tr '\t' ' ')
  local region=""

  echo "Available AWS regions:" >&2
  for r in $regions; do
    echo "- $r" >&2
  done

  while true; do
    read -p "Enter AWS region [$default_region]: " region
    region=${region:-$default_region}

    if [[ " $regions " == *" $region "* ]]; then
      echo "Selected region: $region" >&2
      break
    else
      echo "Invalid region '$region'. Please try again." >&2
    fi
    done
  echo "$region"
}

REGION=$(prompt_for_region)
echo "$REGION" > "$REGION_FILE_PATH"


# generate keys
if [ -f "$PRIVATE_KEY_PATH" ]; then
  echo "SSH key already exists at $PRIVATE_KEY_PATH. Skipping key generation."
else
  echo "Generating SSH key pair '$KEY_NAME' to '$KEY_DIR'"
  ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY_PATH" -C "$KEY_NAME" -N "" > /dev/null 2>&1
fi


# fetch ip
LOCAL_IP=$(curl -s http://checkip.amazonaws.com)

if [ -z "$LOCAL_IP" ]; then
  echo "Failed to fetch public IP. Exiting."
  exit 1
else
  echo "Your public IP is: $LOCAL_IP"
fi


# set up remote resources
if [ ! -d ".terraform" ]; then
  echo "Initializing Terraform..."
  terraform init
fi

echo "Applying Terraform configuration (this might take a while)..."
terraform apply \
  -var "key_pair_name=$KEY_NAME" \
  -var "public_key_path=$PUBLIC_KEY_PATH" \
  -var "allowed_ip=$LOCAL_IP/32" \
  -var "region=$REGION" \
  -auto-approve


# fetch instance ip for tunneling
INSTANCE_IP=$(terraform output -raw public_ip)

if [ -z "$INSTANCE_IP" ]; then
  echo "Failed to obtain instance public IP from Terraform output. Exiting. \
    Run build.sh to try again or destroy.sh to destroy resources."
  exit 1
else
  echo "EC2 instance public IP is: $INSTANCE_IP"
fi

echo "$INSTANCE_IP" > "$IP_FILE_PATH"

echo "Successfully built resources! Next, run tunnel.sh to open the SSH tunnel."