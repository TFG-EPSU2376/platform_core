#!/bin/bash

cd ../domains/core
printf "Deploying core...\n($(pwd))\n"
# terraform init
# terraform import module.storage.aws_dynamodb_table.projects_table ProjectsTable
# terraform import module.storage.aws_dynamodb_table.recommendations_table RecommendationsTable
# terraform import module.storage.aws_dynamodb_table.sensor_data_table SensorDataTable
# terraform import module.storage.aws_dynamodb_table.weather_events_table WeatherEventsTable
# terraform import module.storage.aws_dynamodb_table.alerts_table AlertsTable
# terraform import module.storage.aws_dynamodb_table.device_status_table DeviceStatusTable
# terraform import module.grafana.module.grafana_data_source_dynamodb.module.storage.aws_dynamodb_table.device_status_table DeviceStatusTable
# terraform apply -auto-approve
terraform apply
sleep 4
terraform output -json > output.json
cd ../../utils
