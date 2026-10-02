# acme-hello monitoring

Per-service alerts built from one module and a `services` map.


| Resource (per service) | Purpose                                  |
|------------------------|------------------------------------------|
| 5xx alert              | More than N 5xx per minute for 5 minutes |
| p95 latency alert      | p95 above N ms for 5 minutes             |
| Uptime check and alert | External probe every 5 minutes           |

One shared email notification channel is created at the root.

## Run

```
cp terraform.tfvars.example terraform.tfvars   # set alert_email and host
terraform init
terraform validate
terraform plan
terraform apply
```

`terraform init` must be re-run after adding the module.

## Add a service

Add one entry to `services` in `terraform.tfvars`, then plan and apply.

## Test

Lower `latency_threshold_ms` to 1 and call the service repeatedly, or block
the URL to see the uptime alert. Metrics lag one to two minutes.

## Clean up

```
terraform destroy
```
