#!/bin/bash

./action_terraform_deploy.sh
# printf "USER_POOL_ID path out: $(pwd))\n"
# USER_POOL_ID=$(jq -r '.cognito_user_pool_id.value' ../domains/core/output.json)
# IDENTITY_STORE_ID=$(aws sso-admin list-instances --query "Instances[0].IdentityStoreId" --output text)
# printf "USER_POOL_ID: $USER_POOL_ID\n"
# printf "IDENTITY_STORE_ID: $IDENTITY_STORE_ID\n"
# ./start_create_cognito_users.sh $USER_POOL_ID
#  ./start_create_grafana_users.sh $IDENTITY_STORE_ID

# GRAFANA_ID=$(jq -r '.grafana_workspace_id.value' ../domains/core/output.json)
# GRAFANA_URL=$(jq -r '.grafana_workspace_url.value' ../domains/core/output.json)
# GRAFANA_ID=g-e3f0a15f02
# GRAFANA_URL=g-e3f0a15f02.grafana-workspace.eu-central-1.amazonaws.com
# SENSORS_DATA_TABLE_NAME=$(jq -r '.dynamodb_sensors_data_table_name.value' ../domains/core/output.json)

# printf "Creando workspace $GRAFANA_ID en $GRAFANA_URL...\n"
# printf "TAbla de datos de Sensores: $SENSORS_DATA_TABLE_NAME\n" 

# ./init_grafana_workspace.sh $GRAFANA_ID $GRAFANA_URL $SENSORS_DATA_TABLE_NAME
 

 