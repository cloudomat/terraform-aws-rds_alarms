# Burstable Instance Monitoring Example

This example demonstrates monitoring RDS burstable instances (db.t3, db.t4g) with focus on CPU credit balance.

## What This Example Monitors

### Burstable-Specific Alarms
- **CPU Credit Balance**: Warns at 100 credits, critical at 50 credits
  - Prevents CPU throttling when credits are exhausted
  - Helps you right-size your instance or switch to unlimited mode

### Standard Performance Alarms
- **CPU Utilization**: Warns at 70%, critical at 90%
- **Read/Write Latency**: Warns at 25ms, critical at 75ms
- **Free Storage Space**: Warns at 20%, critical at 10%

## What Are CPU Credits?

Burstable instances (T3/T4g series) earn CPU credits when idle and spend them during bursts of activity:
- **Baseline Performance**: Each instance size has a baseline (e.g., db.t3.micro = 10% CPU)
- **Burst Performance**: Can burst to 100% CPU by spending credits
- **Credit Exhaustion**: When credits run out, performance drops to baseline

This configuration alerts you before credit exhaustion impacts performance.

## Use Case

Ideal for:
- Development and test databases
- Low-traffic production workloads with occasional bursts
- Cost-optimized databases that need burst capacity
- Applications with predictable quiet periods (nights/weekends)

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your T3/T4g instance ID and SNS topics
terraform init
terraform apply
```

## Requirements

- Existing RDS burstable instance (db.t3.* or db.t4g.*)
- SNS topics for alerts
- Terraform >= 1.5.0
- AWS Provider >= 4.0

## What You Get

This configuration creates **10 alarms**:
- 2 CPU credit balance alarms (warning + critical)
- 2 CPU utilization alarms (warning + critical)
- 2 Read latency alarms (warning + critical)
- 2 Write latency alarms (warning + critical)
- 2 Free storage space alarms (warning + critical)

## When to Use Unlimited Mode

If you frequently hit low credit alarms, consider switching to T3/T4g Unlimited mode, which allows sustained high CPU usage (at additional cost per vCPU-hour above baseline).
