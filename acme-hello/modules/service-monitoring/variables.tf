variable "project_id" { type = string }
variable "service_name" { type = string }
variable "host" { type = string }
variable "notification_channel_id" { type = string }

variable "error_threshold" {
  type    = number
  default = 5
}

variable "latency_threshold_ms" {
  type    = number
  default = 1000
}
