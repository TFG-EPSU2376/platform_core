#!/bin/bash

# python -m pip install boto3
ACCESS_KEY_ID=$1
SECRET_ACCESS_KEY=$2
OWNER_EMAIL=$3
ADMIN_EMAIL=$4
DOMAIN=$5:null
REGION=eu-central-1
 
./init_configure_aws_cli.sh $ACCESS_KEY_ID $SECRET_ACCESS_KEY $REGION
./action_terraform_deploy.sh
printf "USER_POOL_ID path out: $(pwd))\n"
USER_POOL_ID=$(jq -r '.cognito_user_pool_id.value' ../domains/core/output.json)
IDENTITY_STORE_ID=$(aws sso-admin list-instances --query "Instances[0].IdentityStoreId" --output text)
printf "USER_POOL_ID: $USER_POOL_ID\n"
printf "IDENTITY_STORE_ID: $IDENTITY_STORE_ID\n"
 ./start_create_cognito_users.sh $USER_POOL_ID
