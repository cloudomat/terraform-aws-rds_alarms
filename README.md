# RDS Alarms

This module creates CloudWatch alarms for RDS instances.

Each supported metric can be given two thresholds. The first threshold will trigger a "low priority" alarm. This is intended for early notification of unusual system behavior or known potential issues, such as running out of database capacity. The second threshold will trigger a "high priority" alarm. This is intended for situations which require immediate attention and may indicate that downtime of the ElastiCache cluster or services using the cluster is imminent.

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
