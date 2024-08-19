

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
          "dynamodb:Query"
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

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke_${var.function_name}_${var.postfix}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.execution_arn}/*/*"
}


