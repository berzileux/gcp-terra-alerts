terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# One channel shared by every service.
resource "google_monitoring_notification_channel" "email" {
  display_name = "ops-email"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# One module call per entry in var.services.
module "monitoring" {
  for_each = var.services
  source   = "./modules/service-monitoring"

  project_id              = var.project_id
  service_name            = each.key
  host                    = each.value.host
  error_threshold         = each.value.error_threshold
  latency_threshold_ms    = each.value.latency_threshold_ms
  notification_channel_id = google_monitoring_notification_channel.email.id
}
