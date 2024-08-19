resource "aws_dynamodb_table" "device_status_table" {
  name         = "DeviceStatusTable"
  hash_key     = "DeviceId"
  billing_mode = "PAY_PER_REQUEST"


  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name,
      hash_key,
    ]
  }
  attribute {
    name = "DeviceId"
    type = "S"
  }
}





