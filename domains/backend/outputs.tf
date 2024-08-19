

output "data_sensors_url" {
  value = "${aws_api_gateway_stage.portal_api_stage.invoke_url}/data/sensors"
}

output "weather_summary_url" {
  value = "${aws_api_gateway_stage.portal_api_stage.invoke_url}/weather/summary"
}

output "weather_forecast_summary_url" {
  value = "${aws_api_gateway_stage.portal_api_stage.invoke_url}/weather/forecast_summary"
}

output "backend_api_endpoint" {
  value = aws_api_gateway_stage.portal_api_stage.invoke_url
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.portal_api_stage.invoke_url
}
