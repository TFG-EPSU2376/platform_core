# variable "greengrass_core_thing_arn" {
#   description = "The ARN of the Greengrass Core thing"
#   type        = string
# }

# variable "greengrass_core_thing_name" {
#   description = "The name of the Greengrass Core thing"
#   type        = string
# }

# variable "greengrass_core_certificate_arn" {
#   description = "The ARN of the Greengrass Core certificate"
#   type        = string
# }
variable "sensors_data_table_name_arn" {
  description = "The DynamoDB table name for the sensors data table."
  type        = string

}
