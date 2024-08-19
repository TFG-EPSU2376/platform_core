resource "aws_dynamodb_table" "projects_table" {
  name         = "ProjectsTable"
  hash_key     = "projectId"
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
    name = "projectId"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "owner"
    type = "S"
  }

  attribute {
    name = "country"
    type = "S"
  }

  global_secondary_index {
    name            = "OwnerIndex"
    hash_key        = "owner"
    range_key       = "projectId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "CountryIndex"
    hash_key        = "country"
    range_key       = "projectId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "NameIndex"
    hash_key        = "name"
    range_key       = "projectId"
    projection_type = "ALL"
  }
}


