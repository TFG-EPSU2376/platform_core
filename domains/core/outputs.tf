output "aws_admin_user_access_key_id" {
  value = aws_iam_access_key.aws_admin_user_access_key.id
}

output "aws_admin_user_secret_access_key" {
  value     = aws_iam_access_key.aws_admin_user_access_key.secret
  sensitive = true
}

output "cognito_user_pool_id" {
  value = module.aaa.cognito_user_pool_id
}




