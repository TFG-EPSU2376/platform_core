module "cron_weather_alerts" {
  source            = "./lambda_cron_module"
  resource_name     = "cron_weather_events"
  function_name     = "cron_weather_events_function"
  postfix           = "prod"
  lambda_runtime    = "nodejs16.x"
  lambda_source_dir = "${path.module}/../lambda/cron_weather_events/"
  environment_variables = {
    WEATHER_EVENTS_TABLE_NAME = var.weather_events_table_name
    OPENWEATHERMAP_API_KEY    = var.openweathermap_api_key
    LATITUDE                  = var.latitude
    LONGITUDE                 = var.longitude
  }
  cron_schedule = "cron(0 * * * ? *)" # Ejecutar cada hora
}

