variable "sensors_data_table_name" {
  description = "The DynamoDB table name for the sensors data table."
  type        = string
}

variable "alerts_table_name" {
  description = "The DynamoDB table name for the alerts data table."
  type        = string
}

variable "iot_rule_assume_role_arn" {
  description = "The ARN of the IoT Rule Assume Role"
  type        = string
}
variable "vineyard_data_alerts_topic_arn" {
  description = "The ARN of the Vineyard Data Alerts Topic"
  type        = string
}

