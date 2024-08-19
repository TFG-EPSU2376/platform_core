variable "thing_names" {
  description = "Names of the IoT Things"
  type        = list(string)
  default     = ["GreengrassCore", "ESP32_Sensor_1", "ESP32_Sensor_2", "ESP32_Sensor_3", "ESP32_Sensor_4", "ESP32_Sensor_5"]
}

variable "sensors_data_table_name" {
  description = "The DynamoDB table name for the sensors data table."
  type        = string
}

variable "sensors_data_table_name_arn" {
  description = "The DynamoDB table name for the sensors data table."
  type        = string
}

variable "alerts_table_name" {
  description = "The DynamoDB table name for the alerts table."
  type        = string
}

variable "device_status_table_name" {
  description = "The DynamoDB table name for the device status table."
  type        = string
}

variable "device_status_table_name_arn" {
  description = "The DynamoDB table name for the device status table."
  type        = string
}


