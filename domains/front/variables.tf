variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}
variable "cloudfront_origin_path" {
  description = "The CloudFront origin path"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "The price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_All"
}

variable "cloudfront_default_root_object" {
  description = "The default root object for the CloudFront distribution"
  type        = string
  default     = "index.html"
}

variable "api_gateway_url" {
  description = "The API Gateway URL"
  type        = string
}

variable "identity_pool_id" {
  description = "The  Identity Pool ID"
  type        = string
}

variable "user_pool_id" {
  description = "The User Pool ID"
  type        = string
}

variable "user_pool_client_id" {
  description = "The User Pool Client ID"
  type        = string
}
variable "cognito_domain_url" {
  description = "The Cognito Domain URL"
  type        = string
}


