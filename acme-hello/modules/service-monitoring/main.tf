# 5xx responses per minute above the threshold, sustained for 5 minutes.
resource "google_monitoring_alert_policy" "errors" {
  display_name = "${var.service_name} 5xx responses"
  combiner     = "OR"

  conditions {
    display_name = "5xx count above ${var.error_threshold} per minute"
    condition_threshold {
      filter = join(" AND ", [
        "resource.type = \"cloud_run_revision\"",
        "resource.labels.service_name = \"${var.service_name}\"",
        "metric.type = \"run.googleapis.com/request_count\"",
        "metric.labels.response_code_class = \"5xx\"",
      ])
      comparison      = "COMPARISON_GT"
      threshold_value = var.error_threshold
      duration        = "300s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  documentation {
    subject   = "${var.service_name}: 5xx responses"
    content   = "Runbook: add a link here."
    mime_type = "text/markdown"
  }

  notification_channels = [var.notification_channel_id]
}

# p95 request latency in milliseconds above the threshold, sustained for 5 minutes.
resource "google_monitoring_alert_policy" "latency" {
  display_name = "${var.service_name} p95 latency"
  combiner     = "OR"

  conditions {
    display_name = "p95 latency above ${var.latency_threshold_ms} ms"
    condition_threshold {
      filter = join(" AND ", [
        "resource.type = \"cloud_run_revision\"",
        "resource.labels.service_name = \"${var.service_name}\"",
        "metric.type = \"run.googleapis.com/request_latencies\"",
      ])
      comparison      = "COMPARISON_GT"
      threshold_value = var.latency_threshold_ms
      duration        = "300s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_95"
        cross_series_reducer = "REDUCE_MAX"
      }
    }
  }

  documentation {
    subject   = "${var.service_name}: high p95 latency"
    content   = "Runbook: add a link here."
    mime_type = "text/markdown"
  }

  notification_channels = [var.notification_channel_id]
}

# External probe every 5 minutes. Catches an unreachable service even when
# there is no traffic to produce metrics.
resource "google_monitoring_uptime_check_config" "this" {
  display_name = "${var.service_name} uptime"
  timeout      = "10s"
  period       = "300s"

  http_check {
    path         = "/"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.host
    }
  }
}

# Fires when the check has failed from more than one location.
resource "google_monitoring_alert_policy" "uptime" {
  display_name = "${var.service_name} uptime check failing"
  combiner     = "OR"

  conditions {
    display_name = "uptime check failing"
    condition_threshold {
      filter = join(" AND ", [
        "metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\"",
        "metric.labels.check_id = \"${google_monitoring_uptime_check_config.this.uptime_check_id}\"",
        "resource.type = \"uptime_url\"",
      ])
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      duration        = "60s"
      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.*"]
      }
    }
  }

  documentation {
    subject   = "${var.service_name}: uptime check failing"
    content   = "Runbook: add a link here."
    mime_type = "text/markdown"
  }

  notification_channels = [var.notification_channel_id]
}
