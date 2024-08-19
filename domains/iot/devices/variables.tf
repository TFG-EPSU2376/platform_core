variable "device_count" {
  description = "Number of ESP32 devices"
  type        = number
  default     = 5
}

variable "greengrass_core_group_name" {
  description = "The name of the Greengrass Core group"
  type        = string
}

variable "sensor_devices_group_name" {
  description = "The name of the Sensor Devices group"
  type        = string
}
