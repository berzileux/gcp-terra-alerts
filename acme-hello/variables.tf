variable "project_id" {
  type        = string
  description = "GCP project that holds the Cloud Run service"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "service_name" {
  type        = string
  default     = "acme-hello"
  description = "Cloud Run service to watch"
}

variable "alert_email" {
  type        = string
  description = "Address that receives alert emails"
}

variable "response_code_class" {
  type        = string
  default     = "5xx"
  description = "HTTP class to alert on: 2xx, 4xx or 5xx. Use 4xx while testing."
}

variable "threshold" {
  type        = number
  default     = 5
  description = "Responses per minute above which the alert fires"
}
