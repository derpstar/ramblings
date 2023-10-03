#!/bin/bash
#set -x

# 
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <IAM_USERNAME> <ACCESS_KEY_ID>"
    exit 1
fi

IAM_USER="$1"
ACCESS_KEY_ID="$2"

# Initialize Terraform working dir...
terraform init

# Import the existing IAM user and access key to our existing Terraform state.
terraform import aws_iam_user.$IAM_USER $IAM_USER
terraform import aws_iam_access_key.${IAM_USER}_key $IAM_USER/$ACCESS_KEY_ID

# Plan  the changes and save to a plan file.
terraform plan -out=tfplan

# Notify, and ask for confirmation before applying...
echo "Review the Terraform plan. Apply changes? [yes/no]"

read -r CONFIRMATION
if [ "$CONFIRMATION" != "yes" ]; then
    echo "Cancelled. No changes applied."
    exit 1
fi

# Apply Terraform plan...
terraform apply "tfplan"

# remove the plan file.
rm -f tfplan

#__END__
