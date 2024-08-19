output "greengrass_core_group_name" {
  value = aws_iot_thing_group.greengrass_core_group.name
}
output "sensor_devices_group_name" {
  value = aws_iot_thing_group.sensor_devices_group.name
}

