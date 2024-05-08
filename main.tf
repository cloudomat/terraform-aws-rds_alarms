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
      version = ">= 4, < 6"
    }
  }

  required_version = ">= 1.5.0"
}

locals {
  allocated_storage   = var.db_instance.allocated_storage
  storage_type        = var.db_instance.storage_type
  resource_name       = var.db_instance.identifier
  replicate_source_db = var.db_instance.replicate_source_db

  always_on = {
    cpu_utilization = {
      low_value          = var.cpu_utilization_high_threshold
      high_value         = var.cpu_utilization_vhigh_threshold
      metric_postfix     = "%"
      metric_description = "CPU Utilization"
      metric_name        = "CPUUtilization"
      directionality     = "high"
    },
    read_latency = {
      low_value          = try(var.read_latency_high_threshold / 1000.0, null)
      high_value         = try(var.read_latency_vhigh_threshold / 1000.0, null)
      display_low_value  = var.read_latency_high_threshold
      display_high_value = var.read_latency_vhigh_threshold
      metric_description = "Read Latency"
      metric_name        = "ReadLatency"
      metric_postfix     = "ms"
      directionality     = "high"
    },
    write_latency = {
      low_value          = try(var.write_latency_high_threshold / 1000.0, null)
      high_value         = try(var.write_latency_vhigh_threshold / 1000.0, null)
      display_low_value  = var.write_latency_high_threshold
      display_high_value = var.write_latency_vhigh_threshold
      metric_description = "Write Latency"
      metric_name        = "WriteLatency"
      metric_postfix     = "ms"
      directionality     = "high"
    }
  }

  only_replicate = {
    replica_lag = {
      low_value          = var.replica_lag_high_threshold
      high_value         = var.replica_lag_vhigh_threshold
      metric_description = "Replica Lag"
      metric_name        = "ReplicaLag"
      metric_postfix     = " seconds"
      directionality     = "high"
    },
    replica_fault = {
      low_value          = null
      high_value         = var.replication_fault ? -1 : null
      metric_description = ""
      metric_name        = "ReplicaLag"
      directionality     = "low"
      alarm_name         = "RDS ${local.resource_name} Replication Fault"
      period             = 60
      alarm_description  = "${local.resource_name} has ceased replicating from the primary DB"
    }
  }

  only_burstable = {
    cpu_credit_balance = {
      low_value          = var.cpu_credit_balance_low_threshold
      high_value         = var.cpu_credit_balance_vlow_threshold
      metric_description = "CPU Credit Balance"
      metric_name        = "CPUCreditBalance"
      directionality     = "low"
    }
  }

  only_known_storage = {
    free_storage_space = {
      low_value          = try(coalesce(local.allocated_storage, 0) * (var.free_storage_space_percentage_low_threshold / 100.0), null)
      high_value         = try(coalesce(local.allocated_storage, 0) * (var.free_storage_space_percentage_vlow_threshold / 100.0), null)
      display_low_value  = var.free_storage_space_percentage_low_threshold
      display_high_value = var.free_storage_space_percentage_vlow_threshold
      metric_description = "Free Storage Space"
      metric_name        = "FreeStorageSpace"
      metric_postfix     = "%"
      directionality     = "low"
    }
  }

  only_burstable_storage = {
    burst_balance = {
      low_value          = var.burst_balance_low_threshold
      high_value         = var.burst_balance_vlow_threshold
      metric_postfix     = "%"
      metric_description = "Burst Balance"
      metric_name        = "BurstBalance"
      directionality     = "low"
    }
  }

  relevant_alarms = merge(
    local.always_on,
    var.db_instance.allocated_storage != null ? local.only_known_storage : {},
    # In our accout DB instances with more than 1TB storage do not report a BurstBalance metric even
    # when using gp2 disks.
    var.db_instance.storage_type == "gp2" && (local.allocated_storage == null || coalesce(local.allocated_storage, 0) < 1000) ? local.only_burstable_storage : {},
    var.db_instance.replicate_source_db != null && local.replicate_source_db != "" ? local.only_replicate : {},
    startswith(var.db_instance.instance_class, "db.t") ? local.only_burstable : {}
  )

  low_priority_alarms  = { for key, value in local.relevant_alarms : "low_${key}" => merge(value, { level = "", value = value["low_value"], display_value = lookup(value, "display_low_value", value["low_value"]) }) if value["low_value"] != null }
  high_priority_alarms = { for key, value in local.relevant_alarms : "high_${key}" => merge(value, { level = "high", value = value["high_value"], display_value = lookup(value, "display_high_value", value["high_value"]) }) if value["high_value"] != null }
  alarms               = merge(local.low_priority_alarms, local.high_priority_alarms)
}

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = local.alarms

  alarm_name = coalesce(
    lookup(each.value, "alarm_name", null),
    join(
      " ",
      compact([
        "RDS",
        local.resource_name,
        each.value["metric_description"],
        each.value["level"] == "high" ? "Very" : null,
        each.value["directionality"] == "high" ? "High" : "Low"
      ])
    )
  )

  alarm_description = coalesce(
    lookup(each.value, "alarm_description", null),
    "${local.resource_name} ${each.value["metric_description"]} is ${each.value["directionality"] == "high" ? "above" : "below"} ${each.value["display_value"]}${try(each.value["metric_postfix"], "")}"
  )

  metric_name = each.value["metric_name"]
  namespace   = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = local.resource_name
  }

  comparison_operator = each.value["directionality"] == "high" ? "GreaterThanOrEqualToThreshold" : "LessThanOrEqualToThreshold"
  evaluation_periods  = lookup(each.value, "evaluation_periods", 1)
  statistic           = lookup(each.value, "statistic", "Average")
  period              = lookup(each.value, "period", 300)
  threshold           = each.value["value"]

  alarm_actions = each.value["level"] == "high" ? var.high_priority_alarm : var.low_priority_alarm
  ok_actions    = each.value["level"] == "high" ? var.high_priority_alarm : var.low_priority_alarm

  tags = var.tags
}

moved {
  from = aws_cloudwatch_metric_alarm.burst_balance_low
  to   = aws_cloudwatch_metric_alarm.alarms["low_burst_balance"]
}

moved {
  from = aws_cloudwatch_metric_alarm.burst_balance_vlow
  to   = aws_cloudwatch_metric_alarm.alarms["high_burst_balance"]
}

moved {
  from = aws_cloudwatch_metric_alarm.read_latency_high
  to   = aws_cloudwatch_metric_alarm.alarms["low_read_latency"]
}

moved {
  from = aws_cloudwatch_metric_alarm.read_latency_vhigh
  to   = aws_cloudwatch_metric_alarm.alarms["high_read_latency"]
}

moved {
  from = aws_cloudwatch_metric_alarm.write_latency_high
  to   = aws_cloudwatch_metric_alarm.alarms["low_write_latency"]
}

moved {
  from = aws_cloudwatch_metric_alarm.write_latency_vhigh
  to   = aws_cloudwatch_metric_alarm.alarms["high_write_latency"]
}

moved {
  from = aws_cloudwatch_metric_alarm.fss_low
  to   = aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"]
}

moved {
  from = aws_cloudwatch_metric_alarm.fss_vlow
  to   = aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"]
}

moved {
  from = aws_cloudwatch_metric_alarm.cpu_high
  to   = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"]
}

moved {
  from = aws_cloudwatch_metric_alarm.cpu_vhigh
  to   = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"]
}

moved {
  from = aws_cloudwatch_metric_alarm.replica_lag_high[0]
  to   = aws_cloudwatch_metric_alarm.alarms["low_replica_lag"]
}

moved {
  from = aws_cloudwatch_metric_alarm.replica_lag_vhigh[0]
  to   = aws_cloudwatch_metric_alarm.alarms["high_replica_lag"]
}

moved {
  from = aws_cloudwatch_metric_alarm.cpu_credit_balance_low
  to   = aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"]
}

moved {
  from = aws_cloudwatch_metric_alarm.cpu_credit_balance_vlow
  to   = aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"]
}

moved {
  from = aws_cloudwatch_metric_alarm.replica_broken[0]
  to   = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"]
}
