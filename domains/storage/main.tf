
resource "random_pet" "dynamo_table_name" {
  length    = 2
  separator = "-"
}


output "dynamodb_projects_table_name" {
  value = aws_dynamodb_table.projects_table.name
}

output "dynamodb_projects_table_arn" {
  value = aws_dynamodb_table.projects_table.arn
}

output "dynamodb_recommendations_table_name" {
  value = aws_dynamodb_table.recommendations_table.name
}

output "dynamodb_recommendations_table_arn" {
  value = aws_dynamodb_table.recommendations_table.arn
}

output "dynamodb_sensors_data_table_name" {
  value = aws_dynamodb_table.sensor_data_table.name
}
output "dynamodb_sensors_data_table_arn" {
  value = aws_dynamodb_table.sensor_data_table.arn
}

output "dynamodb_weather_events_table_name" {
  value = aws_dynamodb_table.weather_events_table.name
}

output "dynamodb_weather_events_table_arn" {
  value = aws_dynamodb_table.weather_events_table.arn
}

output "dynamodb_alerts_table_name" {
  value = aws_dynamodb_table.alerts_table.name
}

output "dynamodb_alerts_table_arn" {
  value = aws_dynamodb_table.alerts_table.arn
}

output "dynamodb_device_status_table_name" {
  value = aws_dynamodb_table.device_status_table.name
}

output "dynamodb_device_status_table_arn" {
  value = aws_dynamodb_table.device_status_table.arn
}
