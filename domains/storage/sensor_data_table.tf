resource "aws_dynamodb_table" "sensor_data_table" {
  name         = "SensorDataTable"
  hash_key     = "DeviceID"
  range_key    = "TimestampAttribute"
  billing_mode = "PAY_PER_REQUEST"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name,
      hash_key,
      range_key,
      attribute,
      global_secondary_index,
    ]
  }

  attribute {
    name = "DeviceID"
    type = "S"
  }

  attribute {
    name = "TimestampAttribute"
    type = "S"
  }

  attribute {
    name = "Category"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  attribute {
    name = "Value"
    type = "N"
  }

  attribute {
    name = "TimestampDeviceID"
    type = "S"
  }

  global_secondary_index {
    name            = "CategoryTimestampDeviceIDIndex"
    hash_key        = "Category"
    range_key       = "TimestampDeviceID"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "DeviceIDTimestampIndex"
    hash_key        = "DeviceID"
    range_key       = "Timestamp"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "DeviceIDCategoryIndex"
    hash_key        = "DeviceID"
    range_key       = "Category"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "CategoryValueIndex"
    hash_key        = "Value"
    range_key       = "Timestamp"
    projection_type = "ALL"
  }
}
