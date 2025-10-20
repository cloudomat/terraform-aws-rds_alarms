terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to fetch your read replica instance details
data "aws_db_instance" "replica" {
  db_instance_identifier = var.db_instance_identifier
}

# Create RDS CloudWatch alarms optimized for read replica monitoring
module "rds_alarms" {
  source = "cloudomat/rds_alarms/aws"

  db_instance = data.aws_db_instance.replica

  # SNS topics for notifications
  low_priority_alarm  = [var.low_priority_sns_topic]
  high_priority_alarm = [var.high_priority_sns_topic]

  # Replication monitoring (only applies to read replicas)
  replica_lag_high_threshold  = 60   # Warning at 60 seconds lag
  replica_lag_vhigh_threshold = 300  # Critical at 5 minutes lag
  replication_fault           = true # Alert when replication stops

  # CPU monitoring (slightly lower thresholds for replicas)
  cpu_utilization_high_threshold  = 70
  cpu_utilization_vhigh_threshold = 90

  # Read latency monitoring (replicas are read-heavy, so focus on read latency)
  read_latency_high_threshold  = 30   # Warning at 30ms
  read_latency_vhigh_threshold = 100  # Critical at 100ms

  # Storage monitoring
  free_storage_space_percentage_low_threshold  = 20
  free_storage_space_percentage_vlow_threshold = 10
}
