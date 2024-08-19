resource "aws_dynamodb_table" "recommendations_table" {
  name         = "RecommendationsTable"
  hash_key     = "recommendationId"
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
    name = "recommendationId"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  global_secondary_index {
    name            = "CreatedAtIndex"
    hash_key        = "createdAt"
    range_key       = "recommendationId"
    projection_type = "ALL"
  }
}
