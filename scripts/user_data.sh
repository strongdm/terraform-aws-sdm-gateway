#!/usr/bin/bash

# Do updates
apt update -y

# Install required helper apps
apt install -y unzip awscli jq

# Fetch the StrongDM admin token from AWS Secrets Manager
ADMIN_TOKEN_KEY=${ADMIN_TOKEN_SECRET_KEY}
ADMIN_TOKEN=$(aws secretsmanager get-secret-value --secret-id "${ADMIN_TOKEN_SECRET_NAME}" --region "${AWS_REGION}" --query SecretString --output text  | jq -r .$ADMIN_TOKEN_KEY)

# Set the StrongDM admin token variable in a way that systemctl can use it
systemctl set-environment SDM_ADMIN_TOKEN=$ADMIN_TOKEN

# Restart the StrongDM gateway setup script (the script included with the StrongDM Gateway AMI)
systemctl restart sdm-relay-setup

# Unset the SDM_ADMIN_TOKEN in systemctl because sdm-proxy fails to start if it has this and SDM_RELAY_TOKEN
systemctl unset-environment SDM_ADMIN_TOKEN

# Enable and restart sdm-proxy
systemctl enable sdm-proxy
systemctl restart sdm-proxy