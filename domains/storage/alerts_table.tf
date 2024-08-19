resource "aws_dynamodb_table" "alerts_table" {
  name         = "AlertsTable"
  hash_key     = "alertId"
  billing_mode = "PAY_PER_REQUEST"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name,
      hash_key,
      attribute,
      global_secondary_index,
    ]
  }
  attribute {
    name = "alertId"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  global_secondary_index {
    name            = "CreatedAtIndex"
    hash_key        = "createdAt"
    range_key       = "alertId"
    projection_type = "ALL"
  }
}

