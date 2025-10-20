# Minimal RDS Alarms Example

This example demonstrates a production-ready starter configuration with essential RDS CloudWatch alarms.

## What This Example Monitors

- **CPU Utilization**: Warns at 80%, critical at 95%
- **Read/Write Latency**: Warns at 20ms, critical at 50ms
- **Free Storage Space**: Warns at 20%, critical at 10%

## Usage

1. Copy this example to your own Terraform configuration
2. Update `terraform.tfvars.example` with your values and rename to `terraform.tfvars`
3. Run `terraform init` and `terraform apply`

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your RDS instance ID and SNS topics
terraform init
terraform apply
```

## Time to Deploy

⏱️ **< 10 minutes** from copy to working alarms

## Requirements

- Existing RDS database instance
- SNS topics for low and high priority alerts (or use the same topic for both)
- Terraform >= 1.5.0
- AWS Provider >= 4.0

## What You Get

This minimal configuration creates **8 alarms**:
- 2 CPU alarms (warning + critical)
- 2 Read latency alarms (warning + critical)
- 2 Write latency alarms (warning + critical)
- 2 Free storage space alarms (warning + critical)

All alarms use sensible production defaults that work for most use cases.
