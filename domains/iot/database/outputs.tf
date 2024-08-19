output "dynamodb_iot_data_table_name" {
  value = aws_dynamodb_table.iot_data.name
}

output "dynamodb_iot_data_table_arn" {
  value = aws_iam_role.iot_role.arn
}

# output "iot_rule_name" {
#   value = aws_iot_topic_rule.iot_rule.name
# }
