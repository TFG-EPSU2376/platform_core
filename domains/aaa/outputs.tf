output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.cognito_user_pool.id
}
output "cognito_domain_url" {
  value = aws_cognito_user_pool_domain.cognito_user_pool_domain.domain
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.cognito_user_pool_client_portal.id
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.identity_pool.id
}

