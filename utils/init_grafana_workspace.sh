#!/bin/bash

WORKSPACE_ID=$1
WORKSPACE_ENDPOINT=$2
SENSORS_DATA_TABLE_NAME=$3

printf "Creando workspace $WORKSPACE_ID en $WORKSPACE_ENDPOINT...\n"
printf "TAbla de datos de Sensores: $SENSORS_DATA_TABLE_NAME\n"
# Función para verificar el estado del workspace
check_workspace_status() {
  aws grafana describe-workspace --workspace-id $WORKSPACE_ID --query "workspace.status" --output text
}

# Esperar a que el workspace esté activo
echo "Esperando a que el workspace esté activo..."
STATUS=$(check_workspace_status)
while [ "$STATUS" != "ACTIVE" ]; do
  echo "Estado actual: $STATUS. Esperando 30 segundos..."
  sleep 30
  STATUS=$(check_workspace_status)
done
echo "El workspace está activo."

API_KEY_FILE="grafana_api_key.txt"

# Comprobar si existe un archivo con la API key
if [ -f "$API_KEY_FILE" ]; then
    API_KEY=$(cat "$API_KEY_FILE")
    echo "API key recuperada del archivo local: $API_KEY"
else
    # Crear una nueva API key
    API_KEY=$(aws grafana create-workspace-api-key --workspace-id $WORKSPACE_ID --key-name "AdminApiKey" --key-role ADMIN --seconds-to-live 1209600 --query "key" --output text)
    
    if [ $? -eq 0 ]; then
        echo "Nueva API key creada: $API_KEY"
        echo "$API_KEY" > "$API_KEY_FILE"
    else
        echo "Error creando la API key"
    fi
fi
 


curl -X POST -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" \
  -d '{
    "dashboard": {
      "id": null,
      "uid": null,
      "title": "Athena Dashboard",
      "tags": [ "Athena" ],
      "timezone": "browser",
      "schemaVersion": 16,
      "version": 0,
      "refresh": "5s",
      "panels": [
        {
          "title": "Athena Query",
          "type": "table",
          "datasource": "grafana-athena-datasource",
          "targets": [
            {
              "format": "table",
              "expr": "SELECT * FROM '$SENSORS_DATA_TABLE_NAME' LIMIT 50",
              "datasource": "Athena"
            }
          ]
        }
      ]
    },
    "overwrite": false
  }' \
  https://$WORKSPACE_ENDPOINT/api/dashboards/db

echo "Dashboard de Athena creado."