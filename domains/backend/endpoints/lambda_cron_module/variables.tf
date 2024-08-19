variable "resource_name" {
  type        = string
  description = "The name of the resource (used in naming the IAM role)"
}

variable "function_name" {
  type        = string
  description = "The name of the Lambda function"
}

variable "postfix" {
  type        = string
  description = "A postfix to add to resource names for uniqueness"
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime for the Lambda function"
}

variable "lambda_source_dir" {
  type        = string
  description = "The directory containing the Lambda function code"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
}

variable "cron_schedule" {
  type        = string
  description = "The cron schedule expression for when to trigger the Lambda function"
}

# variable "lambda_input" {
#   type        = any
#   description = "The input to pass to the Lambda function when it's invoked by the CloudWatch event"
# }
 
