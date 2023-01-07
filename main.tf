# Copyright 2023 Teak.io, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3, < 5"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "burst_balance_low" {
  alarm_name        = "${var.db_instance_identifier} Burst Balance Low"
  alarm_description = "${var.db_instance_identifier} disk iops burst balance is below ${var.burst_balance_low_threshold}%"

  metric_name = "BurstBalance"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  threshold           = var.burst_balance_low_threshold

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "burst_balance_vlow" {
  alarm_name        = "${var.db_instance_identifier} Burst Balance Very Low"
  alarm_description = "${var.db_instance_identifier} disk iops burst balance is below ${var.burst_balance_vlow_threshold}%"

  metric_name = "BurstBalance"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  threshold           = var.burst_balance_vlow_threshold

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "read_latency_high" {
  alarm_name        = "${var.db_instance_identifier} Read Latency High"
  alarm_description = "${var.db_instance_identifier} read latency is above ${var.read_latency_high_threshold * 1000}ms"

  metric_name = "ReadLatency"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "900"
  threshold           = var.read_latency_high_threshold

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "read_latency_vhigh" {
  alarm_name        = "${var.db_instance_identifier} Read Latency Very High"
  alarm_description = "${var.db_instance_identifier} read latency is above ${var.read_latency_vhigh_threshold * 1000}ms"

  metric_name = "ReadLatency"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "900"
  threshold           = var.read_latency_vhigh_threshold

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "write_latency_high" {
  alarm_name        = "${var.db_instance_identifier} Write Latency High"
  alarm_description = "${var.db_instance_identifier} write latency is above ${var.write_latency_high_threshold * 1000}ms"

  metric_name = "WriteLatency"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "900"
  threshold           = var.write_latency_high_threshold

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "write_latency_vhigh" {
  alarm_name        = "${var.db_instance_identifier} Write Latency Very High"
  alarm_description = "${var.db_instance_identifier} write latency is above ${var.write_latency_vhigh_threshold * 1000}ms"

  metric_name = "WriteLatency"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "900"
  threshold           = var.write_latency_vhigh_threshold

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "fss_low" {
  alarm_name        = "${var.db_instance_identifier} Free Storage Space Low"
  alarm_description = "${var.db_instance_identifier} free storage space is below ${format("%.0f", var.fss_fraction_low_threshold * 100)}%"

  metric_name = "FreeStorageSpace"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"

  threshold = var.fss_fraction_low_threshold * var.allocated_storage * 1024 * 1024 * 1024

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "fss_vlow" {
  alarm_name        = "${var.db_instance_identifier} Free Storage Space Very Low"
  alarm_description = "${var.db_instance_identifier} free storage space is below ${format("%.0f", var.fss_fraction_vlow_threshold * 100)}%"

  metric_name = "FreeStorageSpace"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"

  threshold = var.fss_fraction_vlow_threshold * var.allocated_storage * 1024 * 1024 * 1024

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "fss_clow" {
  alarm_name        = "${var.db_instance_identifier} Free Storage Space CRITICALLY Low"
  alarm_description = "${var.db_instance_identifier} free storage space is below ${format("%.0f", var.fss_amount_critical_threshold)}GB"

  metric_name = "FreeStorageSpace"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"

  threshold = var.fss_amount_critical_threshold * 1024 * 1024 * 1024

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name        = "${var.db_instance_identifier} CPU Utilization High"
  alarm_description = "${var.db_instance_identifier} cpu utilization is above ${var.cpu_utilization_high_threshold}%"

  metric_name = "CPUUtilization"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  statistic           = "Average"
  period              = "60"
  threshold           = var.cpu_utilization_high_threshold

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_vhigh" {
  alarm_name        = "${var.db_instance_identifier} CPU Utilization Very High"
  alarm_description = "${var.db_instance_identifier} cpu utilization is above ${var.cpu_utilization_vhigh_threshold}%"

  metric_name = "CPUUtilization"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  statistic           = "Average"
  period              = "60"
  threshold           = var.cpu_utilization_vhigh_threshold

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "replica_lag_high" {
  count = var.replicate_source_db == "" ? 0 : 1

  alarm_name        = "${var.db_instance_identifier} Replica Lag High"
  alarm_description = "${var.db_instance_identifier} replica lag is above ${var.replica_lag_high_threshold}s"

  metric_name = "ReplicaLag"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  statistic           = "Average"
  period              = "60"
  threshold           = var.replica_lag_high_threshold

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "replica_lag_vhigh" {
  count = var.replicate_source_db == "" ? 0 : 1

  alarm_name        = "${var.db_instance_identifier} Replica Lag Very High"
  alarm_description = "${var.db_instance_identifier} replica lag is above ${var.replica_lag_vhigh_threshold}s"

  metric_name = "ReplicaLag"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  statistic           = "Average"
  period              = "60"
  threshold           = var.replica_lag_vhigh_threshold

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "replica_broken" {
  count = var.replicate_source_db == "" ? 0 : 1

  alarm_name        = "${var.db_instance_identifier} Replica Not Replicating"
  alarm_description = "${var.db_instance_identifier} has ceased replicating from the primary DB"

  metric_name = "ReplicaLag"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "60"
  threshold           = -1

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_low" {
  count = substr(var.db_instance_class, 0, 4) == "db.t" ? 1 : 0

  alarm_name        = "${var.db_instance_identifier} CPU Credit Balance Low"
  alarm_description = "${var.db_instance_identifier} cpu credit balance is below ${var.cpu_credit_balance_low_threshold}%"

  metric_name = "CPUCreditBalance"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  threshold           = var.cpu_credit_balance_low_threshold

  alarm_actions = var.low_priority_alarm
  ok_actions    = var.low_priority_alarm

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_vlow" {
  count = substr(var.db_instance_class, 0, 4) == "db.t" ? 1 : 0

  alarm_name        = "${var.db_instance_identifier} CPU Credit Balance Very Low"
  alarm_description = "${var.db_instance_identifier} cpu credit balance is below ${var.cpu_credit_balance_vlow_threshold}%"

  metric_name = "CPUCreditBalance"
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  threshold           = var.cpu_credit_balance_vlow_threshold

  alarm_actions = var.high_priority_alarm
  ok_actions    = var.high_priority_alarm

  tags = var.tags
}
