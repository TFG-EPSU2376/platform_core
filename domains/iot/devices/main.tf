
resource "random_pet" "random_name" {
  length    = 2
  separator = "_"
}

resource "aws_iot_thing" "esp32_sensors" {
  count = var.device_count
  name  = "ESP32_Sensor_${count.index}"
}

resource "aws_iot_certificate" "esp32_certificates" {
  count  = var.device_count
  active = true
}

resource "aws_iot_thing_principal_attachment" "esp32_attachment" {
  count     = var.device_count
  thing     = aws_iot_thing.esp32_sensors[count.index].name
  principal = aws_iot_certificate.esp32_certificates[count.index].arn
}

resource "aws_iot_policy" "esp32_policy" {
  name   = "ESP32Policy_${random_pet.random_name.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iot:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iot_policy_attachment" "esp32_policy_attachment" {
  count  = var.device_count
  policy = aws_iot_policy.esp32_policy.name
  target = aws_iot_certificate.esp32_certificates[count.index].arn
}


resource "aws_iot_thing" "internal_device" {
  name = "GreengrassInternalDevice"
}
resource "aws_iot_certificate" "internal_device_cert" {
  active = true
}

resource "aws_iot_policy" "internal_device_policy" {
  name   = "GreengrassV2IoTThingPolicyInternalDevice_${random_pet.random_name.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iot:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "greengrass:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iot_policy_attachment" "internal_device_policy_attach" {
  policy = aws_iot_policy.internal_device_policy.name
  target = aws_iot_certificate.internal_device_cert.arn
}

resource "aws_iot_thing_principal_attachment" "core_device_attachment" {
  thing     = aws_iot_thing.internal_device.name
  principal = aws_iot_certificate.internal_device_cert.arn
}


resource "local_file" "cert_pem" {
  content  = aws_iot_certificate.internal_device_cert.certificate_pem
  filename = "${path.module}/certs/internal_device/device.pem.crt"
}

resource "local_file" "private_key" {
  content  = aws_iot_certificate.internal_device_cert.private_key
  filename = "${path.module}/certs/internal_device/private.pem.key"
}

resource "local_file" "public_key" {
  content  = aws_iot_certificate.internal_device_cert.public_key
  filename = "${path.module}/certs/internal_device/public.pem.key"
}

resource "aws_iot_thing_group_membership" "greengrass_core_membership" {
  thing_group_name = var.greengrass_core_group_name
  thing_name       = aws_iot_thing.internal_device.name
}

resource "aws_iot_thing_group_membership" "sensor_devices_membership" {
  thing_group_name = var.sensor_devices_group_name
  thing_name       = aws_iot_thing.internal_device.name
}
