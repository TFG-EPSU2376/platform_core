
variable "email" {
  description = "Email del usuario para el cual se crearán las credenciales IAM"
  type        = string
}

variable "region" {
  description = "Región de la instancia de AWS"
  type        = string
  default     = "eu-central-1"
}
