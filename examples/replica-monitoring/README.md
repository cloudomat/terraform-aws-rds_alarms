# Read Replica Monitoring Example

This example demonstrates monitoring an RDS read replica with focus on replication lag and fault detection.

## What This Example Monitors

### Replication-Specific Alarms
- **Replica Lag**: Warns at 60 seconds, critical at 300 seconds
- **Replication Fault Detection**: Alerts when replication stops completely

### Standard Performance Alarms
- **CPU Utilization**: Warns at 70%, critical at 90%
- **Read Latency**: Warns at 30ms, critical at 100ms (replicas are read-heavy)
- **Free Storage Space**: Warns at 20%, critical at 10%

## Use Case

Read replicas are critical for:
- Offloading read traffic from the primary database
- Geographic distribution of data
- Analytics and reporting workloads

This configuration ensures you're alerted when replication lag could impact data freshness or when replication fails entirely.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your read replica ID and SNS topics
terraform init
terraform apply
```

## Requirements

- Existing RDS read replica instance
- SNS topics for alerts
- Terraform >= 1.5.0
- AWS Provider >= 4.0

## What You Get

This configuration creates **10 alarms**:
- 2 Replica lag alarms (warning + critical)
- 1 Replication fault alarm (critical)
- 2 CPU alarms (warning + critical)
- 2 Read latency alarms (warning + critical)
- 2 Free storage space alarms (warning + critical)

## Key Features

**Replication Fault Detection**: The module detects when the ReplicaLag metric stops reporting (indicating replication has stopped) and triggers a high-priority alarm.
