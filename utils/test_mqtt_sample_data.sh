#!/bin/bash

# wget -O ../domains/iot/devices/certs/internal_device/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

IOT_HOST=iot
GW_NAME=1
WS_NAME=2
S1_NAME=1
S2_NAME=2
S3_NAME=3

THING_NAME=GreengrassInternalDevice
# THING_NAME=ESP32_Sensor_1
 
send_data() {
  local sensor_name=$1
  local temperature=$2
  local humidity=$3
  local rain=$4

  timestamp=$(date +%s)
  message="[{\"sensor\":\"$sensor_name\",\"timestamp\":$timestamp"

  if [ -n "$temperature" ]; then
    message+=",\"temperature\":$temperature"
  fi

  if [ -n "$humidity" ]; then
    message+=",\"humidity\":$humidity"
  fi

  if [ -n "$rain" ]; then
    message+=",\"rain\":$rain"
  fi

  message+="}]"

  TOPIC="iot/test"

  echo "Sending data to $THING_NAME on topic "$TOPIC": $message"

  python3 ../../aws-iot-device-sdk-python-v2/samples/basic_discovery.py \
    --thing_name $THING_NAME \
    --topic "$TOPIC" \
    --message "$" \
    --ca_file ../domains/iot/devices/certs/internal_device/AmazonRootCA1.pem \
    --cert ../domains/iot/devices/certs/internal_device/device.pem.crt \
    --key ../domains/iot/devices/certs/internal_device/private.pem.key \
    --region eu-central-1 \
    --verbosity Warn
}

start_time=$(date +%s)

while True
do
  temp=$(( RANDOM % 35 + 15 ))    # Random temperature between 15 and 50
  hum=$(( RANDOM % 50 + 30 ))     # Random humidity between 30 and 80
  rain=$(( RANDOM % 20 + 1 ))     # Random rain between 1 and 20

  # Calculate the timestamp for the current iteration
  timestamp=$((start_time + (i * 60)))  # Add i minutes to the start time

  case $((RANDOM % 3)) in
    0)
      send_data "SM_${S1_NAME}" $temp $hum $rain $timestamp
      ;;
    1)
      send_data "SM_${S1_NAME}" $temp "" "" $timestamp
      ;;
    2)
      send_data "SM_${S1_NAME}" "" $hum "" $timestamp
      ;;
  esac
done