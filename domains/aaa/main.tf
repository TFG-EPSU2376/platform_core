resource "random_pet" "random_name" {
  length    = 2
  separator = ""
}
variable "cognito_user_pool_name" {
  description = "The name of the Cognito User Pool"
  type        = string
}

variable "domain_name" {
  description = "The name of the domain User Pool"
  type        = string
}

resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = var.cognito_user_pool_name

  lifecycle {
    ignore_changes = [
      password_policy[0].temporary_password_validity_days
    ]
  }
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "cognito_user_pool_client_grafana" {
  name         = "grafana-app-client-${random_pet.random_name.id}"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  generate_secret = false

  allowed_oauth_flows          = ["code"]
  allowed_oauth_scopes         = ["phone", "email", "openid", "profile"]
  supported_identity_providers = ["COGNITO"]
  callback_urls                = ["https://your-grafana-url.com/callback"]
  logout_urls                  = ["https://your-grafana-url.com/logout"]
}


resource "aws_cognito_user_pool_client" "cognito_user_pool_client_portal" {
  name         = "portal-app-client-${random_pet.random_name.id}"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  generate_secret = false

  allowed_oauth_flows          = ["code"]
  allowed_oauth_scopes         = ["phone", "email", "openid", "profile"]
  supported_identity_providers = ["COGNITO"]
  callback_urls                = ["https://your-react-app.com/callback"]
  logout_urls                  = ["https://your-react-app.com/logout"]

  access_token_validity  = 24 # En minutos, rango permitido 5 minutos a 24 horas (1440 minutos)
  id_token_validity      = 24 # En minutos, rango permitido 5 minutos a 24 horas (1440 minutos)
  refresh_token_validity = 30 # En días, rango permitido 1 día a 10 años (3650 días)

}

# resource "aws_cognito_user_pool_client" "cognito_user_pool_client_backoffice" {
#   name         = "backoffice-app-client"
#   user_pool_id = aws_cognito_user_pool.example.id

#   explicit_auth_flows = [
#     "ALLOW_USER_PASSWORD_AUTH",
#     "ALLOW_REFRESH_TOKEN_AUTH",
#     "ALLOW_USER_SRP_AUTH",
#     "ALLOW_ADMIN_USER_PASSWORD_AUTH"
#   ]

#   generate_secret = true

#   allowed_oauth_flows       = ["code"]
#   allowed_oauth_scopes      = ["phone", "email", "openid", "profile"]
#   supported_identity_providers = ["COGNITO"]
#   callback_urls = ["https://your-backoffice-url.com/callback"]
#   logout_urls   = ["https://your-backoffice-url.com/logout"]
# }



resource "aws_cognito_user_pool_domain" "cognito_user_pool_domain" {
  domain       = format("%sdomain", var.domain_name)
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
}

# resource "aws_cognito_identity_provider" "google" {
#   user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
#   provider_name = "Google"
#   provider_type = "Google"
#   provider_details = {
#     client_id        = "YOUR_GOOGLE_CLIENT_ID"
#     client_secret    = "YOUR_GOOGLE_CLIENT_SECRET"
#     authorize_scopes = "openid profile email"
#   }
#   attribute_mapping = {
#     email    = "email"
#     username = "sub"
#   }
# }

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "iot_identity_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.cognito_user_pool_client_portal.id
    provider_name = "cognito-idp.eu-central-1.amazonaws.com/${aws_cognito_user_pool.cognito_user_pool.id}"
  }
}
