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

# Data source to fetch your burstable RDS instance details
data "aws_db_instance" "database" {
  db_instance_identifier = var.db_instance_identifier
}

# Create RDS CloudWatch alarms optimized for burstable (T3/T4g) instances
module "rds_alarms" {
  source  = "cloudomat/rds_alarms/aws"
  version = "~> 0.4.0"

  db_instance = data.aws_db_instance.database

  # SNS topics for notifications
  low_priority_alarm  = [var.low_priority_sns_topic]
  high_priority_alarm = [var.high_priority_sns_topic]

  # CPU credit balance monitoring (only applies to T3/T4g instances)
  # Lower thresholds for credit balance are more conservative
  cpu_credit_balance_low_threshold  = 100  # Warning at 100 credits remaining
  cpu_credit_balance_vlow_threshold = 50   # Critical at 50 credits remaining

  # CPU utilization monitoring
  cpu_utilization_high_threshold  = 70  # Lower threshold since burstable
  cpu_utilization_vhigh_threshold = 90

  # Latency monitoring
  read_latency_high_threshold  = 25
  read_latency_vhigh_threshold = 75
  write_latency_high_threshold  = 25
  write_latency_vhigh_threshold = 75

  # Storage monitoring
  free_storage_space_percentage_low_threshold  = 20
  free_storage_space_percentage_vlow_threshold = 10
}
