resource "random_pet" "random_name" {
  length    = 2
  separator = ""
}
provider "aws" {
  region = "eu-central-1"
}
resource "aws_api_gateway_rest_api" "portal_api" {
  name        = "portal_api"
  description = "API for weather information"
}

resource "aws_api_gateway_resource" "project_settings_resource" {
  rest_api_id = aws_api_gateway_rest_api.portal_api.id
  parent_id   = aws_api_gateway_rest_api.portal_api.root_resource_id
  path_part   = "project"
}
resource "aws_api_gateway_resource" "summary_resource" {
  rest_api_id = aws_api_gateway_rest_api.portal_api.id
  parent_id   = aws_api_gateway_rest_api.portal_api.root_resource_id
  path_part   = "summary"
}

resource "aws_api_gateway_resource" "weather_resource" {
  rest_api_id = aws_api_gateway_rest_api.portal_api.id
  parent_id   = aws_api_gateway_rest_api.portal_api.root_resource_id
  path_part   = "weather"
}

resource "aws_api_gateway_resource" "data_resource" {
  rest_api_id = aws_api_gateway_rest_api.portal_api.id
  parent_id   = aws_api_gateway_rest_api.portal_api.root_resource_id
  path_part   = "data"
}

module "backend_endpoints" {
  source                     = "./endpoints/"
  openweathermap_api_key     = var.openweathermap_api_key
  api_id                     = aws_api_gateway_rest_api.portal_api.id
  root_resource_id           = aws_api_gateway_rest_api.portal_api.root_resource_id
  execution_arn              = aws_api_gateway_rest_api.portal_api.execution_arn
  meteostat_api_key          = var.meteostat_api_key
  agromonitoring_api_id      = var.agromonitoring_api_id
  projects_table_name        = var.projects_table_name
  sensors_data_table_name    = var.sensors_data_table_name
  weather_events_table_name  = var.weather_events_table_name
  recommendations_table_name = var.recommendations_table_name
  alerts_table_name          = var.alerts_table_name
  api_resource_project_id    = aws_api_gateway_resource.project_settings_resource.id
  api_resource_weather_id    = aws_api_gateway_resource.weather_resource.id
  api_resource_data_id       = aws_api_gateway_resource.data_resource.id
  api_resource_summary_id    = aws_api_gateway_resource.summary_resource.id
  latitude                   = 0.0
  longitude                  = 0.0
  vineyard_polygon_id        = "VINEYARD_POLYGON_ID"

}

resource "aws_api_gateway_deployment" "portal_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.portal_api.id

  depends_on = [
    aws_api_gateway_rest_api.portal_api,
    module.backend_endpoints
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "portal_api_stage" {
  deployment_id = aws_api_gateway_deployment.portal_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.portal_api.id
  stage_name    = "stage_${random_pet.random_name.id}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_deployment.portal_api_deployment,
    module.backend_endpoints,
  ]
}

locals {
  lambda_modules = [
    "cron_weather_events_function",
    "get_alerts_function",
    "get_data_sensors_function",
    "get_project_settings_function",
    # "get_summary_status_function",
    # "get_summary_sensors_function",
    # "get_summary_satellite_function",
    # "get_satellite_data_function",
    # "get_satellite_day_data_function",
    # "get_satellite_data_history_function",
    # "get_recommendations_function",
    # "get_weather_events_function",
    # "get_weather_rain_forecast_function",
    # "sat_ndvi_function",
    # "summary_weather_dashboard_function",
    # "summary_weather_forecast_function"
  ]

  lambda_file_hashes = [for module in local.lambda_modules :
    filebase64sha256("${path.module}/endpoints/lambda/builds/${module}.zip")
  ]

  combined_hash = sha256(join("", local.lambda_file_hashes))
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.portal_api.id
  stage_name  = "stage_${random_pet.random_name.id}"

  # depends_on = [module.backend_endpoints]
  # triggers = {
  #   redeployment = local.combined_hash
  # }
}
