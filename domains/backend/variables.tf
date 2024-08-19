

variable "openweathermap_api_key" {
  description = "variable to store the openweathermap api key"
  type        = string
}
variable "agromonitoring_api_id" {
  description = "The OpenWeatherMap API key"
  type        = string
}

variable "meteostat_api_key" {
  description = "The Meteosat API key"
  type        = string
}

variable "projects_table_name" {
  description = "The DynamoDB table name for the projects table."
  type        = string
}

variable "sensors_data_table_name" {
  description = "The DynamoDB table name for the sensors data table."
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
