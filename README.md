# RDS Alarms

This module creates CloudWatch alarms for RDS instances.

Each supported metric can be given two thresholds. The first threshold will trigger a "low priority" alarm. This is intended for early notification of unusual system behavior or known potential issues, such as running out of database capacity. The second threshold will trigger a "high priority" alarm. This is intended for situations which require immediate attention and may indicate that downtime of the ElastiCache cluster or services using the cluster is imminent.

## Examples

See the [examples/](examples/) directory for complete, working configurations:

- **[minimal/](examples/minimal/)** - Production-ready starter with essential alarms (CPU, latency, storage)
- **[replica-monitoring/](examples/replica-monitoring/)** - Read replica with lag and fault detection
- **[performance-monitoring/](examples/performance-monitoring/)** - Advanced monitoring with p99 latency tracking
- **[burstable-instance/](examples/burstable-instance/)** - T3/T4g instances with CPU credit balance monitoring
- **[complete/](examples/complete/)** - All features enabled (reference configuration)

Each example includes `README.md`, `main.tf`, `variables.tf`, and `terraform.tfvars.example` for quick deployment.

## Installation

This is a complete example of a minimal set of alarms.

```hcl
provider "aws" {}

variable "db_instance_identifier" {
  type        = string
  description = "The identifier of a RDS DB instance."
}

data "aws_db_instance" "instance" {
  db_instance_identifier = var.db_instance_identifier
}

module "alarms" {
  source = "cloudomat/rds_alarms/aws"

  db_instance = data.aws_db_instance.instance

  low_priority_alarm  = []
  high_priority_alarm = []
}
```

## Custom Alarms

In addition to the built-in alarms for common RDS metrics, you can define custom alarms for any CloudWatch metric using the `custom_alarms` variable.

### Basic Usage

```hcl
module "alarms" {
  source = "cloudomat/rds_alarms/aws"

  db_instance = data.aws_db_instance.instance

  low_priority_alarm  = [aws_sns_topic.alerts_low.arn]
  high_priority_alarm = [aws_sns_topic.alerts_high.arn]

  # Built-in alarms
  cpu_utilization_high_threshold  = 80
  cpu_utilization_vhigh_threshold = 95

  # Custom alarms
  custom_alarms = {
    "connection_availability" = {
      metric_name    = "DatabaseConnections"
      low_threshold  = 20   # Warning when too few connections
      vlow_threshold = 10   # Critical when too few connections
      description    = "Database Connections"
      unit           = " connections"
    }
  }
}
```

### Bidirectional Alarming

You can alarm on both high AND low values for the same metric, useful for detecting both overload and unavailability:

```hcl
custom_alarms = {
  "connection_health" = {
    metric_name     = "DatabaseConnections"
    high_threshold  = 1000  # Warning when too many connections
    vhigh_threshold = 1500  # Critical when too many connections
    low_threshold   = 20    # Warning when too few connections
    vlow_threshold  = 10    # Critical when too few connections
    description     = "Database Connections"
    unit            = " connections"
  }
}
```

This creates 4 separate alarms:
- Warning when > 1000 connections (low priority)
- Critical when > 1500 connections (high priority)
- Warning when < 20 connections (low priority)
- Critical when < 10 connections (high priority)

### Available Options

- `metric_name` (required): The CloudWatch metric name (e.g., "DatabaseConnections", "NetworkReceiveThroughput")
- `high_threshold`: Low priority alarm when metric > threshold
- `vhigh_threshold`: High priority alarm when metric > threshold
- `low_threshold`: Low priority alarm when metric < threshold
- `vlow_threshold`: High priority alarm when metric < threshold
- `description`: Human-readable name for the alarm (defaults to metric name)
- `unit`: Unit suffix for alarm descriptions (e.g., "ms", "%", " connections")
- `statistic`: CloudWatch statistic (default: "Average")
- `period`: Evaluation period in seconds (default: 300)
- `evaluation_periods`: Number of periods before alarming (default: 1)

All custom alarms automatically use the AWS/RDS namespace and include the DBInstanceIdentifier dimension.
