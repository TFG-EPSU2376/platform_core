resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "s3_iot_core" {
  bucket        = "iot-core-${random_pet.random_name.id}"
  force_destroy = true
}
resource "aws_iot_thing_group" "greengrass_core_group" {
  name = "GreengrassCoreGroup"
}

resource "aws_iot_thing_group" "sensor_devices_group" {
  name = "SensorDevicesGroup"
}

