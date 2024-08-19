#!/bin/bash

printf "Testing Iot Rules...\n"


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

  TOPIC="test"

  echo "Sending data to $THING_NAME on topic "$TOPIC": $message"

  python3 ../../aws-iot-device-sdk-python-v2/samples/basic_discovery.py \
    --thing_name $THING_NAME \
    --topic "$TOPIC" \
    --message "$message" \
    --ca_file ../domains/iot/devices/certs/internal_device/AmazonRootCA1.pem \
    --cert ../domains/iot/devices/certs/internal_device/device.pem.crt \
    --key ../domains/iot/devices/certs/internal_device/private.pem.key \
    --region eu-central-1 \
    --verbosity Warn
}

start_time=$(date +%s)

# Test Water Stress Alert
echo "Testing Water Stress Alert"
send_data "SM_1" 15 "" "" ""
sleep 5

# Test Phylloxera Favorable Conditions Alert
echo "Testing Phylloxera Favorable Conditions Alert"
send_data "SM_1" 65 25 "" ""
sleep 5

# Test Grape Moth Favorable Conditions Alert
echo "Testing Grape Moth Favorable Conditions Alert"
send_data "SM_1" "" "" 20 ""
sleep 5

# Test Downy Mildew Favorable Conditions Alert
echo "Testing Downy Mildew Favorable Conditions Alert"
send_data "SM_1" "" "" 18 96
sleep 5

# Test Powdery Mildew Favorable Conditions Alert
echo "Testing Powdery Mildew Favorable Conditions Alert"
send_data "SM_1" "" "" 24 55
sleep 5

echo "All tests completed"