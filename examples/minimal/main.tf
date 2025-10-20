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

# Data source to fetch your existing RDS instance details
data "aws_db_instance" "database" {
  db_instance_identifier = var.db_instance_identifier
}

# Create RDS CloudWatch alarms with sensible defaults
module "rds_alarms" {
  source  = "cloudomat/rds_alarms/aws"
  version = "~> 0.4.0"

  db_instance = data.aws_db_instance.database

  # SNS topics for notifications
  low_priority_alarm  = [var.low_priority_sns_topic]
  high_priority_alarm = [var.high_priority_sns_topic]

  # CPU monitoring
  cpu_utilization_high_threshold  = 80  # Warning at 80%
  cpu_utilization_vhigh_threshold = 95  # Critical at 95%

  # Latency monitoring
  read_latency_high_threshold  = 20  # Warning at 20ms
  read_latency_vhigh_threshold = 50  # Critical at 50ms
  write_latency_high_threshold  = 20  # Warning at 20ms
  write_latency_vhigh_threshold = 50  # Critical at 50ms

  # Storage monitoring
  free_storage_space_percentage_low_threshold  = 20  # Warning at 20% free
  free_storage_space_percentage_vlow_threshold = 10  # Critical at 10% free
}
