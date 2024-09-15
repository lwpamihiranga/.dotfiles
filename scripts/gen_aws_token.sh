#!/bin/bash

echo "mfa_token: $1"

if [ -z "$aws_mfa_arn" ]; then
  echo "aws_mfa_arn env variable is not set"
  exit 1
fi

json_string=$(aws sts get-session-token --serial-number $aws_mfa_arn --token-code $1)

echo "$json_string"

# Extract and format params with "export " prefix
params=$(echo "$json_string" | jq -r '.Credentials | to_entries[] | select(.key != "Expiration") | "export " + .key + "=" + .value')

# Transform the key values
output_string=$(echo "$params" | sed -E 's/export AccessKeyId=/export AWS_ACCESS_KEY_ID=/g; s/export SecretAccessKey=/export AWS_SECRET_ACCESS_KEY=/g; s/export SessionToken=/export AWS_SESSION_TOKEN=/g')

echo "$output_string"
