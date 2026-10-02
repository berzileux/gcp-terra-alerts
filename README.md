# gcp-terra-alerts

Terraform for Cloud Monitoring alerts on a Cloud Run service.

## What it creates

| Resource | Purpose |
|---|---|
| `google_monitoring_notification_channel.email` | Where alerts are sent |
| `google_monitoring_alert_policy.cloud_run_errors` | Fires when the chosen HTTP class exceeds the threshold per minute |

## One-time setup

```
gcloud auth login --no-launch-browser
gcloud auth application-default login --no-launch-browser
gcloud config set project <project-abc>
gcloud auth application-default set-quota-project <project-abc>
gcloud services enable monitoring.googleapis.com
```

## Run

```
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars and set alert_email
terraform init
terraform validate
terraform plan
terraform apply
```

`plan` previews and changes nothing. `apply` creates the resources.

## Test the alert

With `response_code_class = "4xx"` and `threshold = 3`, request a URL that does
not exist on the service about ten times:

```
for i in $(seq 1 10); do curl -s -o /dev/null https://YOUR-SERVICE-URL/nope; done
```

Metrics lag one to two minutes, so wait about five minutes for the email.

## Clean up

```
terraform destroy
```

## Notes

- `terraform.tfvars` and state files are git-ignored. Do not commit them.
- Local state is fine for practice. For a team, use a remote backend in a
  Cloud Storage bucket.
- Switch `response_code_class` to `5xx` and raise `duration` (for example
  `"300s"`) in `main.tf` for real use.
