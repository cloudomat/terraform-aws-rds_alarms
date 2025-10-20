# Performance Monitoring Example

This example demonstrates advanced performance monitoring using **percentile-based alarms** for latency tracking.

## What This Example Monitors

### Advanced Latency Monitoring (Using Percentiles)
- **p99 Read Latency**: Critical alarm at 100ms
- **p99 Write Latency**: Critical alarm at 100ms
- **p95 CPU Utilization**: Warning at 85%

### Why Percentiles Matter

Average latency can hide performance issues. The p99 latency tells you the worst experience that 99% of your users see:
- **Average = 20ms**: Looks good, but hides outliers
- **p99 = 200ms**: 1% of requests take >200ms (critical for user experience!)

This example uses CloudWatch extended statistics to track p95 and p99 metrics.

## Standard Monitoring
- **CPU**: Warning at 80%, critical at 95%
- **Free Storage**: Warning at 20%, critical at 10%

## Use Case

Ideal for:
- Production databases with strict SLA requirements
- User-facing applications where tail latency matters
- Identifying performance degradation before it impacts most users

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your database ID and SNS topics
terraform init
terraform apply
```

## Requirements

- Existing RDS database instance
- SNS topics for alerts
- Terraform >= 1.5.0
- AWS Provider >= 4.0

## What You Get

This configuration creates **11 alarms**:
- 2 p99 Read latency alarms (using extended statistics)
- 2 p99 Write latency alarms (using extended statistics)
- 1 p95 CPU alarm (using extended statistics)
- 2 Standard CPU alarms (warning + critical)
- 2 Free storage alarms (warning + critical)
- 2 Database connections alarms (too high or too low)

## Key Features

**Extended Statistics**: Uses CloudWatch's percentile metrics (p95, p99) for more accurate performance tracking.

**Bidirectional Connection Monitoring**: Alarms on both very high connection counts (overload) and very low counts (availability issues).
