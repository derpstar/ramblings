#!/bin/bash

## This is a generic example for retrieving keys
## mostly derived from documentation.
## IBM Cloud CLI must be installed


#source ../libs/examples 

# Set API key
API_KEY="YOUR_API_KEY"
# URL

# Local key dir
LOCAL_DIR="ssh_keys"

# Login to IBM Cloud
ibmcloud login --apikey "$API_KEY" -r us-south

SECRET_MANAGER_ID="YOUR_SECRET_MANAGER_ID"

# Loop through secrets and download...
for SECRET_NAME in secret1 secret2 secret3; do
    # Get secrets...
    SECRET=$(ibmcloud secrets-manager secret get --id "$SECRET_MANAGER_ID" --secret-name "$SECRET_NAME" --json)
    
    # Get key from payload...
    # PEM_CONTENT=$(echo "$SECRET" | jq -r '.resources[0].secret_data.private_key')
    PEM_CONTENT=$(echo "$SECRET" | jq -r '.payload')

    # Write out secrets
    echo "$PEM_CONTENT" > "$LOCAL_DIR/$SECRET_NAME.pem"
done

ibmcloud logout
##__END__
