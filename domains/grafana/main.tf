variable "grafana_dashboard_folder_name" {
  description = "Folder name created on grafana istance"
  type        = string
  default     = "stage"
}

variable "dashboard_file_path" {
  description = "Grafana dashboard file  local path"
  type        = string
  default     = "dashboards/"
}

resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}



resource "aws_s3_bucket" "athena_output" {
  bucket = "iot-athena-output-bucket-${random_pet.random_name.id}"
}

resource "aws_s3_bucket_public_access_block" "athena_output" {
  bucket = aws_s3_bucket.athena_output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_iam_role" "athena_role" {
  name = "AthenaRole_${random_pet.random_name.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        },
        Action = "sts:AssumeRole"
        }, {
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "athena_policy" {
  name        = "AthenaPolicy"
  description = "Policy for Athena to access S3 and DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
        ],
        Resource = [
          aws_s3_bucket.athena_output.arn,
          "${aws_s3_bucket.athena_output.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "grafana:*",
          "athena:*",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_athena_policy" {
  role       = aws_iam_role.athena_role.name
  policy_arn = aws_iam_policy.athena_policy.arn
}


resource "aws_iam_role" "grafana_role" {
  name = "GrafanaWorkspaceRole_${random_pet.random_name.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "grafana_policy" {
  name = "grafana_policy_${random_pet.random_name.id}"

  description = "Policy for accessing the Grafana workspace"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "grafana:*",
          "s3:*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "cloudwatch:*",
          "logs:*",
          "athena:*",
          "lambda:InvokeFunction"
        ]
        Resource = "*"
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "grafana_role_policy_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}




resource "aws_grafana_workspace" "workspace_of_portal_grafana" {
  name = "portal-grafana-workspace_${random_pet.random_name.id}"

  account_access_type = "CURRENT_ACCOUNT"
  # authentication_providers = ["AWS_SSO", "COGNITO"]
  authentication_providers = ["AWS_SSO", ]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana_role.arn
  # cognito_config {
  #   user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  #   client_id    = aws_cognito_user_pool_client.cognito_user_pool_client_grafana.id
  #   domain       = aws_cognito_user_pool_domain.cognito_user_pool_domain.domain
  # }
}


resource "null_resource" "enable_plugin_management" {
  depends_on = [aws_grafana_workspace.workspace_of_portal_grafana]

  provisioner "local-exec" {
    command = <<EOT
      aws grafana update-workspace-configuration --workspace-id ${aws_grafana_workspace.workspace_of_portal_grafana.id} --configuration '{"plugins": {"pluginAdminEnabled": true}}'
    EOT
  }
}




module "grafana_data_source_dynamodb" {
  source = "./datasources/dynamodb"
  # cognito_user_pool_name = "of_core_u_p"
}


resource "aws_grafana_workspace_api_key" "grafana_api_key_viewer" {
  key_name        = "grafana_api_key_viewe_key_${random_pet.random_name.id}"
  key_role        = "VIEWER"
  seconds_to_live = 3600
  workspace_id    = aws_grafana_workspace.workspace_of_portal_grafana.id
}

resource "aws_grafana_workspace_api_key" "grafana_api_key_admin" {
  key_name        = "grafana_api_key_viewe_keyy_${random_pet.random_name.id}"
  key_role        = "ADMIN"
  seconds_to_live = 3600
  workspace_id    = aws_grafana_workspace.workspace_of_portal_grafana.id
}




resource "aws_iam_user" "grafana_viewer" {
  name = "grafana_viewer"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.grafana_viewer.name
}

data "aws_iam_policy_document" "lb_ro" {
  statement {
    effect    = "Allow"
    actions   = ["grafana:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "lb_ro" {
  name   = "User_grafana_viewer_${random_pet.random_name.id}"
  user   = aws_iam_user.grafana_viewer.name
  policy = data.aws_iam_policy_document.lb_ro.json
}
