#!/bin/bash
#set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <IAM_USERNAME>"
    exit 1
fi

IAM_USER="$1"

# Get the Access Key details...
ACCESS_KEY_DETAILS=$(aws iam list-access-keys --user-name "$IAM_USER")

if [ -z "$ACCESS_KEY_DETAILS" ]; then
  echo "Failed to fetch access key details for provided IAM user: $IAM_USER"
  exit 1
fi

# Extract Access Key ID if any access key exists...
ACCESS_KEY_ID=$(echo $ACCESS_KEY_DETAILS | jq -r '.AccessKeyMetadata[0].AccessKeyId' )

# or bail...
if [ "$ACCESS_KEY_ID" == "null" ]; then
  echo "No access keys found for IAM user: $IAM_USER"
  exit 1
fi

# Initialize Terraform working directory...
# the steps below may be better off being ran manually.
terraform init

# Import the existing IAM user and access key to the Terraform state.
terraform import aws_iam_user.$IAM_USER $IAM_USER
terraform import aws_iam_access_key.${IAM_USER}_key $IAM_USER/$ACCESS_KEY_ID

# Plan changes and save it to plan file...
terraform plan -out=tfplan

# Notify, and ask for confirmation before applying plan.
echo "Review the Terraform plan. Apply changes? [yes/no]"

read -r CONFIRMATION
if [ "$CONFIRMATION" != "yes" ]; then
    echo "Cancelled. No changes were applied."
    exit 1
fi

# Apply...
terraform apply "tfplan"

# Remove gebnerated plan file.
rm -f tfplan
