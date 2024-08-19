
resource "random_pet" "random_name" {
  length    = 2
  separator = "_"
}

resource "aws_sns_topic" "vineyard_data_alerts" {
  name = "vineyard-alerts-topic"
}


resource "aws_iam_role" "iot_rule_assume_role" {
  name = "iot_rule_assume_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "iot.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}




data "archive_file" "data_sensors_to_dynamodb_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/mqtt_data_to_dynamodb/"
  output_path = "${path.module}/../lambda/builds/get_data_sensors.zip"
  excludes    = []
}

resource "aws_lambda_function" "data_sensors_to_dynamodb_function" {
  filename      = data.archive_file.data_sensors_to_dynamodb_zip.output_path
  function_name = "data_sensors_to_dynamodb_function_${random_pet.random_name.id}"
  role          = aws_iam_role.iot_rule_assume_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      SENSOR_DATA_TABLE_NAME = var.sensors_data_table_name
    }
  }
  source_code_hash = filebase64sha256(data.archive_file.data_sensors_to_dynamodb_zip.output_path)
}

resource "aws_iot_topic_rule" "IOT_sensors_to_lambda_rule" {
  name        = "IotDataToLambdaRule_${random_pet.random_name.id}"
  description = "Rule to receive IoT data and send to Lambda"
  enabled     = true
  sql         = "SELECT * FROM 'iot/+/+/data'"
  sql_version = "2016-03-23"
  lambda {
    function_arn = aws_lambda_function.data_sensors_to_dynamodb_function.arn
  }
}


data "archive_file" "connected_gateway_to_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/mqtt_connected_gateway_to_dynamodb/"
  output_path = "${path.module}/../lambda/builds/connected_gateway_to_lambda.zip"
  excludes    = []
}

resource "aws_lambda_function" "connected_gateway_to_lambda_function" {
  filename      = data.archive_file.connected_gateway_to_lambda_zip.output_path
  function_name = "connected_gateway_to_lambda_function_${random_pet.random_name.id}"
  role          = aws_iam_role.iot_rule_assume_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      SENSOR_DATA_TABLE_NAME   = var.sensors_data_table_name
      DEVICE_STATUS_TABLE_NAME = var.device_status_table_name
    }
  }
  source_code_hash = filebase64sha256(data.archive_file.connected_gateway_to_lambda_zip.output_path)
}



resource "aws_iot_topic_rule" "IOT_gateway_connected_to_lambda_rule" {
  name        = "IotGatewayConnectedToLambdaRule_${random_pet.random_name.id}"
  description = "Rule to receive IoT gateway connection advice"
  enabled     = true
  sql         = "SELECT * FROM 'iot/+/connected'"
  sql_version = "2016-03-23"
  lambda {
    function_arn = aws_lambda_function.connected_gateway_to_lambda_function.arn
  }
}



module "iot_rules" {
  source                         = "../rules"
  sensors_data_table_name        = var.sensors_data_table_name
  alerts_table_name              = var.alerts_table_name
  iot_rule_assume_role_arn       = aws_iam_role.iot_rule_assume_role.arn
  vineyard_data_alerts_topic_arn = aws_sns_topic.vineyard_data_alerts.arn
}






data "archive_file" "send_alert_email_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/send_alert_email/"
  output_path = "${path.module}/../lambda/builds/send_alert_email.zip"
  excludes    = []
}

resource "aws_lambda_function" "send_alert_email" {
  filename      = data.archive_file.send_alert_email_zip.output_path
  function_name = "send_alert_email"
  role          = aws_iam_role.iot_rule_assume_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {}
  }
  source_code_hash = filebase64sha256(data.archive_file.send_alert_email_zip.output_path)
}

data "archive_file" "send_alert_sms_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/send_alert_sms/"
  output_path = "${path.module}/../lambda/builds/send_alert_sms.zip"
  excludes    = []
}

resource "aws_lambda_function" "send_alert_sms" {
  filename      = data.archive_file.send_alert_sms_zip.output_path
  function_name = "send_alert_sms"
  role          = aws_iam_role.iot_rule_assume_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {}
  }
  source_code_hash = filebase64sha256(data.archive_file.send_alert_sms_zip.output_path)
}

data "archive_file" "send_alert_notification_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/send_alert_notification/"
  output_path = "${path.module}/../lambda/builds/send_alert_notification.zip"
  excludes    = []
}

resource "aws_lambda_function" "send_alert_notification" {
  filename      = data.archive_file.send_alert_notification_zip.output_path
  function_name = "send_alert_notification"
  role          = aws_iam_role.iot_rule_assume_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {}
  }
  source_code_hash = filebase64sha256(data.archive_file.send_alert_notification_zip.output_path)
}






resource "aws_iam_role_policy" "iot_rule_policy" {
  name = "iot_rule_policy"
  role = aws_iam_role.iot_rule_assume_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:*"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "sns:Publish",
          "sns:SetSMSAttributes",
          "sns:CheckIfPhoneNumberIsOptedOut"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
        ]
        Resource = [
          "*",
          aws_lambda_function.send_alert_notification.arn
        ]
      },
      {
        Action = [
          "dynamodb:*",
        ],
        Effect = "Allow",
        Resource = [
          var.device_status_table_name_arn,
          var.sensors_data_table_name_arn,
          "${var.sensors_data_table_name_arn}/index/GSI1"
        ]
      }
    ]
  })
}
