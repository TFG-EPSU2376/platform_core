
resource "random_pet" "random_name" {
  length    = 2
  separator = ""
}

module "get_alerts_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_data_id
  path_part         = "alerts"
  lambda_source_dir = "${path.module}/../lambda/get_alerts/"
  function_name     = "get_alerts_function"
  resource_name     = "alerts_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id

  environment_variables = {
    AGROMONITORING_API_ID = var.agromonitoring_api_id
    ALERTS_TABLE_NAME     = var.alerts_table_name
  }
  execution_arn = var.execution_arn
}

module "get_data_sensors_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_data_id
  path_part         = "sensors"
  lambda_source_dir = "${path.module}/../lambda/get_data_sensors/"
  function_name     = "get_data_sensors_function"
  resource_name     = "data_sensors_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id

  environment_variables = {
    SENSOR_DATA_TABLE_NAME = var.sensors_data_table_name
  }
  execution_arn = var.execution_arn
}

module "get_project_settings_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_project_id
  path_part         = "settings"
  lambda_source_dir = "${path.module}/../lambda/get_project_settings/"
  function_name     = "get_project_settings_function"
  resource_name     = "project_settings_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id

  environment_variables = {
    PROJECTS_TABLE_NAME = var.projects_table_name
  }
  execution_arn = var.execution_arn
}

module "get_summary_status_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_summary_id
  path_part         = "status"
  lambda_source_dir = "${path.module}/../lambda/get_summary_status/"
  function_name     = "get_summary_status_function"
  resource_name     = "summary_status_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    PROJECTS_TABLE_NAME = var.projects_table_name
  }
  execution_arn = var.execution_arn
}

module "get_summary_sensors_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_summary_id
  path_part         = "sensors"
  lambda_source_dir = "${path.module}/../lambda/get_summary_sensors/"
  function_name     = "get_summary_sensors_function"
  resource_name     = "summary_sensors_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    PROJECTS_TABLE_NAME    = var.projects_table_name
    SENSOR_DATA_TABLE_NAME = var.sensors_data_table_name
  }
  execution_arn = var.execution_arn
}


module "get_summary_satellite_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_summary_id
  path_part         = "satellite"
  lambda_source_dir = "${path.module}/../lambda/get_summary_satellite/"
  function_name     = "get_summary_satellite_function"
  resource_name     = "summary_satellite_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    PROJECTS_TABLE_NAME   = var.projects_table_name
    AGROMONITORING_API_ID = var.agromonitoring_api_id
    VINEYARD_POLYGON_ID   = var.vineyard_polygon_id

  }
  execution_arn = var.execution_arn
}


module "get_satellite_data_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_data_id
  path_part         = "satellite"
  lambda_source_dir = "${path.module}/../lambda/get_satellite_data/"
  function_name     = "get_satellite_data_function"
  resource_name     = "satellite_data_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    PROJECTS_TABLE_NAME   = var.projects_table_name
    AGROMONITORING_API_ID = var.agromonitoring_api_id
    VINEYARD_POLYGON_ID   = var.vineyard_polygon_id
  }
  execution_arn = var.execution_arn
}

module "get_satellite_day_data_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_data_id
  path_part         = "satellite_day"
  lambda_source_dir = "${path.module}/../lambda/get_satellite_day_data/"
  function_name     = "get_satellite_day_data_function"
  resource_name     = "satellite_day_data_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    PROJECTS_TABLE_NAME   = var.projects_table_name
    AGROMONITORING_API_ID = var.agromonitoring_api_id
    VINEYARD_POLYGON_ID   = var.vineyard_polygon_id
  }
  execution_arn = var.execution_arn
}

module "get_satellite_data_history_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_data_id
  path_part         = "satellite_history"
  lambda_source_dir = "${path.module}/../lambda/get_satellite_data_history/"
  function_name     = "get_satellite_data_history_function"
  resource_name     = "satellite_data_history_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    PROJECTS_TABLE_NAME   = var.projects_table_name
    AGROMONITORING_API_ID = var.agromonitoring_api_id
    VINEYARD_POLYGON_ID   = var.vineyard_polygon_id
  }
  execution_arn = var.execution_arn
}



module "get_recommendations_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_data_id
  path_part         = "recommendations"
  lambda_source_dir = "${path.module}/../lambda/get_recommendations/"
  function_name     = "get_recommendations_function"
  resource_name     = "recommendations_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id

  environment_variables = {
    RECOMMENDATIONS_TABLE_NAME = var.recommendations_table_name
  }
  execution_arn = var.execution_arn
}


module "get_weather_events_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_weather_id
  path_part         = "events"
  lambda_source_dir = "${path.module}/../lambda/weather_events/"
  function_name     = "get_weather_events_function"
  resource_name     = "weather_events_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id

  environment_variables = {
    METEOSTAT_API_KEY = var.meteostat_api_key
  }
  execution_arn = var.execution_arn
}




module "get_weather_rain_forecast_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_weather_id
  path_part         = "weather_rain_forecast"
  lambda_source_dir = "${path.module}/../lambda/weather_rain_forecast_summary/"
  function_name     = "get_weather_rain_forecast_function"
  resource_name     = "weather_rain_forecast_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id

  environment_variables = {
    METEOSTAT_API_KEY      = var.meteostat_api_key
    OPENWEATHERMAP_API_KEY = var.openweathermap_api_key
  }
  execution_arn = var.execution_arn
}


module "sat_ndvi_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.root_resource_id
  path_part         = "sat_ndvi"
  lambda_source_dir = "${path.module}/../lambda/sat_ndvi_summary/"
  function_name     = "weather_sat_ndvi_function"
  resource_name     = "sat_ndvi_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    AGROMONITORING_API_ID = var.agromonitoring_api_id
  }
  execution_arn = var.execution_arn
}

module "summary_weather_dashboard_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_weather_id
  path_part         = "dashboard"
  lambda_source_dir = "${path.module}/../lambda/weather_summary/"
  function_name     = "summary_weather_dashboard_function"
  resource_name     = "summary_weather_dashboard_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    OPENWEATHERMAP_API_KEY = var.openweathermap_api_key
  }
  execution_arn = var.execution_arn
}

module "summary_weather_forecast_endpoint" {
  source            = "./lambda_endpoint_module"
  api_id            = var.api_id
  root_resource_id  = var.api_resource_weather_id
  path_part         = "weather_forecast"
  lambda_source_dir = "${path.module}/../lambda/weather_forecast_summary/"
  function_name     = "summary_weather_forecast_function"
  resource_name     = "summary_weather_forecast_endpoint_${random_pet.random_name.id}"
  postfix           = random_pet.random_name.id
  environment_variables = {
    OPENWEATHERMAP_API_KEY = var.openweathermap_api_key
  }
  execution_arn = var.execution_arn
}
