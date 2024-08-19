#!/bin/bash

# python -m pip install boto3
ACCESS_KEY_ID=$1
SECRET_ACCESS_KEY=$2
OWNER_EMAIL=$3
ADMIN_EMAIL=$4
DOMAIN=$5:null
REGION=eu-central-1

printf "Credenciales de AWS:\n"
printf "ACCESS_KEY_ID: $ACCESS_KEY_ID\n"
printf "SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY\n"
printf "OWNER_EMAIL: $OWNER_EMAIL\n"
printf "ADMIN_EMAIL: $ADMIN_EMAIL\n"
printf "DOMAIN: $DOMAIN\n"
printf "REGION: $REGION\n"

./init_iam_admin_user.sh $ACCESS_KEY_ID $SECRET_ACCESS_KEY $OWNER_EMAIL $ADMIN_EMAIL $REGION
ACCESS_KEY_ID=$(jq -r '.terraform_user_access_key_id.value' ../domains/core/output.json)
SECRET_ACCESS_KEY=$(jq -r '.terraform_user_secret_access_key.value' ../domains/core/output.json)
printf "URL de la aplicación de AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID\n"
printf "URL de la aplicación de AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY\n"
printf "...Esperando confirmación verificacion apikey...\n"
read -n 1 -s -r -p "Press any key to continue..."

./init_configure_aws_cli.sh $ACCESS_KEY_ID $SECRET_ACCESS_KEY $REGION
./init_verify_emails.sh $OWNER_EMAIL $ADMIN_EMAIL $REGION
printf "...Esperando confirmación verificacion email...\n"
read -n 1 -s -r -p "Press any key to continue..."
./start_deploy.sh 

PORTAL_URL=$(jq -r '.cloudfront_distribution_domain_name.value' ../domains/core/output.json)
GRAFANA_URL=$(jq -r '.grafana_workspace_url.value' ../domains/core/output.json)
BACKEND_URL=$(jq -r '.backend_api_endpoint.value' ../domains/core/output.json)
printf "URL de la aplicación de portal: $PORTAL_URL\n"
printf "URL de la aplicación de Grafana: $GRAFANA_URL\n"
printf "URL de la API de la aplicación de backend: $BACKEND_URL\n"