#!/bin/bash
#set -x

# Credentials, SSH_KEY dirs.
CREDENTIALS_DIR="./credentials"
SSH_KEY_DIR="./local_ssh_keys"

AWS_API_KEY=$(jq -r '.aws.api_key' "${CREDENTIALS_DIR}/aws_credentials.json")
AWS_API_URL=$(jq -r '.aws.api_url' "${CREDENTIALS_DIR}/aws_credentials.json")
AZURE_API_KEY=$(jq -r '.azure.api_key' "${CREDENTIALS_DIR}/azure_credentials.json")
AZURE_API_URL=$(jq -r '.azure.api_url' "${CREDENTIALS_DIR}/azure_credentials.json")

# List of secrets' names and local targets
declare -A secrets=(
    ["aws_secret_name_1"]="aws_local_file_name_1.pem"
    ["aws_secret_name_2"]="aws_local_file_name_2.pem"
    ["azure_secret_name_1"]="azure_local_file_name_1.pem"
    ["azure_secret_name_2"]="azure_local_file_name_2.pem"
)
mkdir -p "${SSH_KEY_DIR}"

fetch_secret() {
    local secret_name="$1"
    local file_name="$2"
    local api_url="$3"
    local api_key="$4"

    curl -s -X GET "${api_url}/v1/secrets/${secret_name}" \
         -H "Authorization: Bearer ${api_key}" \
         -o "${file_name}"
}

for secret_name in "${!secrets[@]}"; do
    echo "Fetching ${secret_name}..."
    if [[ $secret_name == aws_* ]]; then
        api_url=${AWS_API_URL}
        api_key=${AWS_API_KEY}
    elif [[ $secret_name == azure_* ]]; then
        api_url=${AZURE_API_URL}
        api_key=${AZURE_API_KEY}
    else
        echo "Unknown platform for ${secret_name}. Skipping..."
        continue
    fi
    
    fetch_secret "${secret_name}" "${SSH_KEY_DIR}/${secrets[${secret_name}]}" "${api_url}" "${api_key}"
    if [ $? -eq 0 ]; then
        echo "${secret_name} fetched successfully."
        chmod 0400 "${SSH_KEY_DIR}/${secrets[${secret_name}]}"
    else
        echo "Failed to fetch ${secret_name}."
    fi
done

# Secure ssh key dir
chmod 700 "${KEY_DIR}"
