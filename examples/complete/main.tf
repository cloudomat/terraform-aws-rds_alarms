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

# Complete RDS CloudWatch alarms configuration with all features enabled
module "rds_alarms" {
  source  = "cloudomat/rds_alarms/aws"
  version = "~> 0.4.0"

  db_instance = data.aws_db_instance.database

  # SNS topics for notifications
  low_priority_alarm  = [var.low_priority_sns_topic]
  high_priority_alarm = [var.high_priority_sns_topic]

  # ========== BUILT-IN ALARMS ==========

  # CPU monitoring
  cpu_utilization_high_threshold  = 75
  cpu_utilization_vhigh_threshold = 90

  # Latency monitoring (thresholds in milliseconds)
  read_latency_high_threshold  = 20
  read_latency_vhigh_threshold = 50
  write_latency_high_threshold  = 20
  write_latency_vhigh_threshold = 50

  # Storage monitoring
  free_storage_space_percentage_low_threshold  = 25
  free_storage_space_percentage_vlow_threshold = 15

  # Disk I/O monitoring
  disk_queue_depth_high_threshold  = 64
  disk_queue_depth_vhigh_threshold = 128

  # Memory monitoring (thresholds in MB)
  freeable_memory_low_threshold  = 1024  # 1GB
  freeable_memory_vlow_threshold = 512   # 512MB

  # Swap monitoring (thresholds in MB)
  swap_usage_high_threshold  = 512   # 512MB
  swap_usage_vhigh_threshold = 1024  # 1GB

  # Replication monitoring (only applies to read replicas)
  replica_lag_high_threshold  = 60
  replica_lag_vhigh_threshold = 300
  replication_fault           = true

  # Burst balance monitoring (only applies to gp2 storage < 1TB)
  burst_balance_low_threshold  = 50
  burst_balance_vlow_threshold = 20

  # CPU credit monitoring (only applies to T3/T4g instances)
  cpu_credit_balance_low_threshold  = 200
  cpu_credit_balance_vlow_threshold = 100

  # ========== CUSTOM ALARMS ==========

  custom_alarms = {
    # p99 latency tracking with extended statistics
    "p99_read_latency" = {
      metric_name        = "ReadLatency"
      extended_statistic = "p99"
      vhigh_threshold    = 0.100  # 100ms in seconds
      description        = "p99 Read Latency"
      unit               = "s"
      period             = 60
      treat_missing_data = "notBreaching"
    }

    "p99_write_latency" = {
      metric_name        = "WriteLatency"
      extended_statistic = "p99"
      vhigh_threshold    = 0.100  # 100ms in seconds
      description        = "p99 Write Latency"
      unit               = "s"
      period             = 60
      treat_missing_data = "notBreaching"
    }

    # Bidirectional connection monitoring (alarm on high OR low)
    "database_connections" = {
      metric_name     = "DatabaseConnections"
      high_threshold  = 1000  # Warning: too many connections
      vhigh_threshold = 1500  # Critical: connection overload
      low_threshold   = 10    # Warning: suspiciously low activity
      vlow_threshold  = 5     # Critical: possible availability issue
      description     = "Database Connections"
      unit            = " connections"
    }

    # Network throughput monitoring
    "network_receive_low" = {
      metric_name    = "NetworkReceiveThroughput"
      vlow_threshold = 100000  # Critical if less than 100KB/s
      description    = "Network Receive Throughput"
      unit           = " bytes/sec"
    }

    # p95 CPU for early warning
    "p95_cpu" = {
      metric_name        = "CPUUtilization"
      extended_statistic = "p95"
      high_threshold     = 85
      description        = "p95 CPU Utilization"
      unit               = "%"
    }
  }
}
