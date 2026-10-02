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

# Where alert notifications are sent. Email is one channel type; Slack,
# PagerDuty and webhooks are others.
resource "google_monitoring_notification_channel" "email" {
  display_name = "ops-email"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# Alert when Cloud Run returns more than `threshold` responses of the chosen
# class (for example 5xx) within one minute.
resource "google_monitoring_alert_policy" "cloud_run_errors" {
  display_name = "${var.service_name} ${var.response_code_class} responses"
  combiner     = "OR"

  conditions {
    display_name = "${var.response_code_class} count above ${var.threshold} per minute"

    condition_threshold {
      filter = join(" AND ", [
        "resource.type = \"cloud_run_revision\"",
        "resource.labels.service_name = \"${var.service_name}\"",
        "metric.type = \"run.googleapis.com/request_count\"",
        "metric.labels.response_code_class = \"${var.response_code_class}\"",
      ])

      comparison      = "COMPARISON_GT"
      threshold_value = var.threshold

      # 0s fires on the first breaching minute, which is useful for testing.
      # For real use, raise it (for example "300s") so one blip does not alert.
      duration = "0s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  documentation {
    subject   = "${var.service_name} errors"
    content   = "Too many ${var.response_code_class} responses on ${var.service_name}. First check Logs Explorer for the service, then the last deploy. Runbook: add a link here."
    mime_type = "text/markdown"
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}
