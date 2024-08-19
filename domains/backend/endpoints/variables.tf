variable "latitude" {
  type        = string
  description = "Latitude for weather data"
}

variable "longitude" {
  type        = string
  description = "Longitude for weather data"
}
variable "api_resource_weather_id" {
  description = "The parent resource ID"
  type        = string
}

variable "vineyard_polygon_id" {
  description = "value"
  type        = string
}

variable "sensors_data_table_name" {
  description = "The DynamoDB table name for the data table."
  type        = string
}

variable "weather_events_table_name" {
  description = "The DynamoDB table name for the weather events table."
  type        = string
}

variable "recommendations_table_name" {
  description = "The DynamoDB table name for the recommendations table."
  type        = string
}

variable "alerts_table_name" {
  description = "The DynamoDB table name for the alerts table."
  type        = string
}
variable "api_resource_data_id" {
  description = "The parent resource ID"
  type        = string
}

variable "api_resource_summary_id" {
  description = "The parent resource ID"
  type        = string
}

variable "meteostat_api_key" {
  description = "The Meteosat API key"
  type        = string
}

variable "openweathermap_api_key" {
  description = "The OpenWeatherMap API key"
  type        = string
}

variable "api_id" {
  description = "The API ID"
  type        = string
}

variable "root_resource_id" {
  description = "The root_resource_id"
  type        = string
}

variable "execution_arn" {
  description = "The root_resource_id"
  type        = string
}

variable "agromonitoring_api_id" {
  description = "The Agromonitoring API ID"
  type        = string
}

variable "projects_table_name" {
  description = "The DynamoDB table name for the projects table."
  type        = string
}

variable "api_resource_project_id" {
  description = "The parent resource ID"
  type        = string
}
