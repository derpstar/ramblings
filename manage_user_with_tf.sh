#!/bin/bash
#set -x

IAM_USER="$1"

# Get IAM user details...
USER_DETAILS=$(aws iam get-user --user-name "$IAM_USER")

# Get Access Key details for user...
ACCESS_KEY_DETAILS=$(aws iam list-access-keys --user-name "$IAM_USER")

# Mkae sure we have inputs...
if [ -z "$USER_DETAILS" ] || [ -z "$ACCESS_KEY_DETAILS" ]; then
  echo "Failed to fetch details for IAM user: $IAM_USER"
  exit 1
fi

# Get the User ARN...
USER_ARN=$(echo $USER_DETAILS | jq -r .User.Arn)

# Extract Access Key ID...
ACCESS_KEY_ID=$(echo $ACCESS_KEY_DETAILS | jq -r '.AccessKeyMetadata[0].AccessKeyId' )

# Generate Terraform script ...
cat <<EOF > "$IAM_USER".tf
resource "aws_iam_user" "$IAM_USER" {
  name = "$IAM_USER"
  arn  = "$USER_ARN"
}

EOF

# Check if access key exists and append it to terraform...
if [ "$ACCESS_KEY_ID" != "null" ]; then
cat <<EOF >> "$IAM_USER".tf
resource "aws_iam_access_key" "${IAM_USER}_key" {
  user = aws_iam_user.$IAM_USER.name
}
EOF
fi

#__END__
