terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}


resource "random_pet" "random_name" {
  length    = 2
  separator = ""
}
variable "email" {
  description = "Email del usuario para el cual se crearán las credenciales IAM"
  type        = string
}




resource "aws_iam_user" "terraform_user" {
  name = "terraform_user_${random_pet.random_name.id}"
}

resource "aws_iam_access_key" "terraform_access_key" {
  user = aws_iam_user.terraform_user.name
}

resource "aws_iam_user_policy_attachment" "terraform_user_policy_attachment" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "terraform_user_access_key_id" {
  value = aws_iam_access_key.terraform_access_key.id
}

output "terraform_user_secret_access_key" {
  value     = aws_iam_access_key.terraform_access_key.secret
  sensitive = true
}

//from this
//terraform apply -auto-approve -var="email=${$EMAIL}" -var="optional_domain=example.com"

//send  email with access key and secret news to these email
