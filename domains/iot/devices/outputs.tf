output "esp32_thing_names" {
  value = aws_iot_thing.esp32_sensors[*].name
}

output "esp32_certificates" {
  value = aws_iot_certificate.esp32_certificates[*].arn
}
