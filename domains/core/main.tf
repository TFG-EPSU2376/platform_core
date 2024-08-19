
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket  = "iot-epsu-terraform-state"
    region  = "eu-central-1"
    key     = "state/terraform.tfstate"
    encrypt = true
  }
  required_version = ">= 1.2.0"
}



provider "aws" {
  region = var.region
}


resource "random_pet" "s3_bucket_name" {
  length    = 2
  separator = "-"
}


resource "random_pet" "random_names_server" {
  length    = 2
  separator = "-"
}

resource "random_pet" "random_domain" {
  length    = 2
  separator = ""
}

resource "random_pet" "random_name" {
  length    = 2
  separator = "_"
}

resource "aws_iam_user" "aws_admin_user" {
  name = "aws_admin_user_${random_pet.random_name.id}"
}

resource "aws_iam_access_key" "aws_admin_user_access_key" {
  user = aws_iam_user.aws_admin_user.name
}

resource "aws_iam_user_policy_attachment" "aws_admin_user_policy_attachment" {
  user       = aws_iam_user.aws_admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


module "iot" {
  source                       = "../iot"
  sensors_data_table_name      = module.storage.dynamodb_sensors_data_table_name
  sensors_data_table_name_arn  = module.storage.dynamodb_sensors_data_table_arn
  alerts_table_name            = module.storage.dynamodb_alerts_table_name
  device_status_table_name     = module.storage.dynamodb_device_status_table_name
  device_status_table_name_arn = module.storage.dynamodb_device_status_table_arn

  # sensors_data_table_name = module.storage.dynamodb_sensors_data_table_name
  # cognito_user_pool_name = "of_core_u_p"
}

module "backend" {
  source                     = "../backend"
  openweathermap_api_key     = "OPENWEATHERMAP_API_KEY"
  meteostat_api_key          = "METEOSTAT_API_KEY"
  agromonitoring_api_id      = "AGROMONITORING_API_ID"
  projects_table_name        = module.storage.dynamodb_projects_table_name
  sensors_data_table_name    = module.storage.dynamodb_sensors_data_table_name
  weather_events_table_name  = module.storage.dynamodb_weather_events_table_name
  recommendations_table_name = module.storage.dynamodb_recommendations_table_name
  alerts_table_name          = module.storage.dynamodb_alerts_table_name
}


module "front" {
  source              = "../front"
  bucket_name         = "iot-portal-front"
  environment         = "prod"
  api_gateway_url     = module.backend.api_gateway_url
  identity_pool_id    = module.aaa.identity_pool_id
  user_pool_id        = module.aaa.cognito_user_pool_id
  user_pool_client_id = module.aaa.cognito_user_pool_client_id
  cognito_domain_url  = module.aaa.cognito_domain_url
}




module "storage" {
  source = "../storage"
  # cognito_user_pool_name = "of_core_u_p"
}

module "aaa" {
  source                 = "../aaa"
  cognito_user_pool_name = "of_core_u_p"
  domain_name            = random_pet.random_domain.id
}


module "grafana" {
  source                        = "../grafana"
  grafana_dashboard_folder_name = "stage"
  dashboard_file_path           = "dashboards/"
  # cognito_user_pool_name = "of_core_u_p"
}



