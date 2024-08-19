variable "aws_region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "eu-central-1"
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
