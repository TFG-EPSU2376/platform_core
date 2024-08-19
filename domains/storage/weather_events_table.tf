resource "aws_dynamodb_table" "weather_events_table" {
  name         = "WeatherEventsTable"
  hash_key     = "eventId"
  range_key    = "timestamp"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "eventId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "lat"
    type = "N"
  }

  attribute {
    name = "lon"
    type = "N"
  }

  attribute {
    name = "date"
    type = "S"
  }

  attribute {
    name = "description"
    type = "S"
  }

  global_secondary_index {
    name            = "LocationIndex"
    hash_key        = "lat"
    range_key       = "lon"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "DateIndex"
    hash_key        = "date"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

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
}
