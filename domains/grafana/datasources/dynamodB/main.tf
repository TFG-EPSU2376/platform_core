module "storage" {
  source = "../../../storage"
}

resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaExecRole_${random_pet.random_name.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "LambdaDynamoDBPolicy_${random_pet.random_name.id}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [
          module.storage.dynamodb_sensors_data_table_arn,
          "${module.storage.dynamodb_sensors_data_table_arn}/index/CategoryIndex"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}


# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "lambda_function.py"
#   output_path = "lambda_function_payload.zip"
# }


# resource "aws_lambda_function" "dynamodb_query_function" {
#   filename      = data.archive_file.lambda.output_path
#   function_name = "DynamoDBQueryFunction_${random_pet.random_name.id}"
#   role          = aws_iam_role.lambda_exec_role.arn
#   handler       = "lambda_function.handler"
#   runtime       = "python3.8"
#   # source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)
#   source_code_hash = data.archive_file.lambda.output_base64sha256

#   environment {
#     variables = {
#       TABLE_NAME = module.storage.dynamodb_sensors_data_table_name
#     }
#   }
# }

# API Gateway
# resource "aws_api_gateway_rest_api" "dynamodb_api" {
#   name        = "DynamoDBQueryAPI_${random_pet.random_name.id}"
#   description = "API for querying DynamoDB"
# }

# resource "aws_api_gateway_resource" "query_resource" {
#   rest_api_id = aws_api_gateway_rest_api.dynamodb_api.id
#   parent_id   = aws_api_gateway_rest_api.dynamodb_api.root_resource_id
#   path_part   = "query"
# }

# resource "aws_api_gateway_method" "query_get" {
#   rest_api_id   = aws_api_gateway_rest_api.dynamodb_api.id
#   resource_id   = aws_api_gateway_resource.query_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.dynamodb_api.id
#   resource_id             = aws_api_gateway_resource.query_resource.id
#   http_method             = aws_api_gateway_method.query_get.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.dynamodb_query_function.invoke_arn
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   depends_on = [
#     aws_api_gateway_integration.lambda_integration
#   ]

#   rest_api_id = aws_api_gateway_rest_api.dynamodb_api.id
#   stage_name  = "v1"
# }

# output "grafana_api_url" {
#   value = "${aws_api_gateway_deployment.deployment.invoke_url}/query"
# }
