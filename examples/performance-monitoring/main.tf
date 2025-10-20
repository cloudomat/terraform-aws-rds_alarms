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

# Create RDS CloudWatch alarms with advanced performance monitoring
module "rds_alarms" {
  source  = "cloudomat/rds_alarms/aws"
  version = "~> 0.4.0"

  db_instance = data.aws_db_instance.database

  # SNS topics for notifications
  low_priority_alarm  = [var.low_priority_sns_topic]
  high_priority_alarm = [var.high_priority_sns_topic]

  # Standard CPU monitoring
  cpu_utilization_high_threshold  = 80
  cpu_utilization_vhigh_threshold = 95

  # Storage monitoring
  free_storage_space_percentage_low_threshold  = 20
  free_storage_space_percentage_vlow_threshold = 10

  # Custom alarms with extended statistics (percentile-based)
  custom_alarms = {
    # p99 Read Latency - catch tail latency issues
    "p99_read_latency" = {
      metric_name        = "ReadLatency"
      extended_statistic = "p99"                # 99th percentile
      vhigh_threshold    = 0.100                # 100ms in seconds (CloudWatch uses seconds)
      description        = "p99 Read Latency"
      unit               = "s"
      period             = 60
      treat_missing_data = "notBreaching"       # Don't alarm during maintenance
    }

    # p99 Write Latency - catch tail latency issues
    "p99_write_latency" = {
      metric_name        = "WriteLatency"
      extended_statistic = "p99"
      vhigh_threshold    = 0.100                # 100ms in seconds
      description        = "p99 Write Latency"
      unit               = "s"
      period             = 60
      treat_missing_data = "notBreaching"
    }

    # p95 CPU - early warning before hitting average thresholds
    "p95_cpu" = {
      metric_name        = "CPUUtilization"
      extended_statistic = "p95"
      high_threshold     = 85                   # Warning at 85%
      description        = "p95 CPU Utilization"
      unit               = "%"
      period             = 300
    }

    # Connection health - bidirectional monitoring
    "connection_health" = {
      metric_name     = "DatabaseConnections"
      high_threshold  = 1000                    # Too many connections (overload)
      vhigh_threshold = 1500                    # Critical overload
      low_threshold   = 10                      # Too few connections (availability issue)
      vlow_threshold  = 5                       # Critical availability issue
      description     = "Database Connections"
      unit            = " connections"
    }
  }
}
