
resource "random_pet" "random_name" {
  length    = 2
  separator = "_"
}

resource "aws_iam_user" "admin_user" {
  name = "greengrass_admin_user_${random_pet.random_name.id}"
}

resource "aws_iam_user_policy_attachment" "admin_policy_attachment" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


module "aws_iot_core" {
  source                       = "./aws_iot_core"
  sensors_data_table_name      = var.sensors_data_table_name
  sensors_data_table_name_arn  = var.sensors_data_table_name_arn
  alerts_table_name            = var.alerts_table_name
  device_status_table_name     = var.device_status_table_name
  device_status_table_name_arn = var.device_status_table_name_arn
}
module "greengrass" {
  source                      = "./greengrass"
  sensors_data_table_name_arn = var.sensors_data_table_name_arn
}
module "devices" {
  source                     = "./devices"
  greengrass_core_group_name = module.greengrass.greengrass_core_group_name
  sensor_devices_group_name  = module.greengrass.sensor_devices_group_name
}
module "iot_database" {
  source = "./database"
}


