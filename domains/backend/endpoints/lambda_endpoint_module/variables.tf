variable "api_id" {
  type = string
}

variable "root_resource_id" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "path_part" {
  type = string
}

variable "lambda_source_dir" {
  type = string
}

variable "function_name" {
  type = string
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs18.x"
}

variable "environment_variables" {
  type = map(string)
}

variable "execution_arn" {
  type = string
}


variable "postfix" {
  type = string
}

