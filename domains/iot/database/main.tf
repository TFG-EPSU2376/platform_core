resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

resource "aws_dynamodb_table" "iot_data" {
  name         = "IoTDataTable"
  hash_key     = "deviceId"
  range_key    = "timestamp"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "deviceId"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "N"
  }
}

resource "aws_iam_role" "iot_role" {
  name               = "iot_role_${random_pet.random_name.id}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iot_role_policy" {
  name   = "iot_role_policy_${random_pet.random_name.id}"
  role   = aws_iam_role.iot_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:GetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "${aws_dynamodb_table.iot_data.arn}"
    }
  ]
}
EOF
}
