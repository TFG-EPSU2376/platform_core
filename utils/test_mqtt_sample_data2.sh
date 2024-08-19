#!/bin/bash

IOT_HOST=iot
THING_NAME=GreengrassInternalDevice

# Función para enviar datos
send_data() {
    local topic=$1
    local message=$2

    echo "Sending data to $THING_NAME on topic $topic: $message"

    # Escapar correctamente el mensaje JSON
    escaped_message=$(echo "$message" | sed 's/"/\\"/g')

    python3 ../../aws-iot-device-sdk-python-v2/samples/basic_discovery.py \
        --thing_name "$THING_NAME" \
        --topic "$topic" \
        --message "$escaped_message" \
        --ca_file ../domains/iot/devices/certs/internal_device/AmazonRootCA1.pem \
        --cert ../domains/iot/devices/certs/internal_device/device.pem.crt \
        --key ../domains/iot/devices/certs/internal_device/private.pem.key \
        --region eu-central-1 \
        --verbosity Warn

    # Añadir una pausa para evitar sobrecarga
    sleep 1
}

# Función para generar mensaje de conexión
generate_connected_message() {
    local gateway_id=$1
echo '{"info": {"gateway_id": "'"$gateway_id"'", "status": "connected", "timestamp": '"$(date +%s)"'}}'
}

# Función para generar mensaje de sensor de suelo
generate_soil_sensor_message() {
    local gateway_id=$1
    local sensor_id=$2
    local timestamp=$(date +%s)
    local temperature=$((RANDOM % 30 + 10))
    local temperature_raw=$(awk "BEGIN {print $((RANDOM % 3000 + 1000)) / 100}")
    local humidity=$((RANDOM % 60 + 20))
    local humidity_raw=$(awk "BEGIN {print $((RANDOM % 6000 + 2000)) / 100}")

    json_string='{"measurements":[{"sensor":"SM_1","date":"1722202422","data":[{"value":22,"unity":"temperature","raw":"36,23"},{"value":63,"unity":"humidity","raw":"23,73"}]}]}'
    
    clean_json=$(echo "$json_string" | sed 's/^"\(.*\)"$/\1/' | sed 's/\\"/"/g')
    echo "$clean_json"

}

# Función para generar mensaje de estación meteorológica
generate_weather_station_message() {
    local gateway_id=$1
    local sensor_id=$2
    cat << EOF
{
  "weather_measurements": [
    {
      "timestamp": $(date +%s),
      "data": [
        {
          "parameter": "ambient_temperature",
          "value": $((RANDOM % 35 + 5)),
          "unit": "celsius"
        },
        {
          "parameter": "relative_humidity",
          "value": $((RANDOM % 80 + 20)),
          "unit": "percent"
        },
        {
          "parameter": "rainfall",
          "value": $(awk "BEGIN {print $((RANDOM % 50)) / 10}"),
          "unit": "mm"
        }
      ]
    }
  ]
}
EOF
}

# Enviar mensajes de conexión
# for gw in 1 2 3; do
#     topic="iot/gw_${gw}/connected"
#     message=$(generate_connected_message "gw_${gw}")
#     send_data "$topic" "$message"
# done

 

# # Enviar mensajes de sensores de suelo
# for gw in 1 2; do
#     for sensor in 1 2 3; do
#         topic="iot/gw_${gw}/SM_${sensor}/data"
#         message=$(generate_soil_sensor_message "gw_${gw}" "SM_${sensor}")
#         send_data "$topic" "$message"
#     done
# done
for gw in 1 ; do
    for sensor in 1; do
        topic="iot/gw_${gw}/SM_${sensor}/data"
        message=$(generate_soil_sensor_message "gw_${gw}" "SM_${sensor}")
        send_data "$topic" "$message"
    done
done

# # Enviar mensajes de estación meteorológica
# for gw in 1 2; do
#     topic="iot/gw_${gw}/WS_1/data"
#     message=$(generate_weather_station_message "gw_${gw}" "WS_1")
#     send_data "$topic" "$message"
# done