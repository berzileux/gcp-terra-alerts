variable "project_id" {
  type        = string
  description = "GCP project that holds the Cloud Run services"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "alert_email" {
  type        = string
  description = "Address that receives alert emails"
}

variable "services" {
  description = "Cloud Run services to monitor, keyed by service name"
  type = map(object({
    host                 = string
    error_threshold      = optional(number, 5)
    latency_threshold_ms = optional(number, 1000)
  }))
}
