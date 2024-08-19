resource "aws_iam_role" "lambda_role" {
  name = "a_l_${var.resource_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:PutItem"
        ]
        Effect = "Allow"
        Resource = [
          "*",
        ]
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.module}/../lambda/builds/${var.function_name}.zip"
  excludes    = []
}

resource "aws_lambda_function" "lambda_function" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.function_name}_${var.postfix}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = var.lambda_runtime

  environment {
    variables = var.environment_variables
  }

  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
}

resource "aws_cloudwatch_event_rule" "lambda_cron" {
  name                = "${var.function_name}_cron_${var.postfix}"
  description         = "Cron job for ${var.function_name} Lambda function"
  schedule_expression = var.cron_schedule
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_cron.name
  target_id = "Lambda"
  arn       = aws_lambda_function.lambda_function.arn
  # input     = jsonencode(var.lambda_input)
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch_${var.function_name}_${var.postfix}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_cron.arn
}
