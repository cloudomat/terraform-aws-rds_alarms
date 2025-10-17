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

variable "db_instance" {
  type = object({
    identifier          = string
    instance_class      = string
    allocated_storage   = optional(number)
    replicate_source_db = optional(string)
    storage_type        = string
    iops                = optional(number)
  })
}

variable "low_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a low priority alarm"
}

variable "high_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a high priority alarm"
}

variable "burst_balance_low_threshold" {
  type        = number
  default     = 70
  description = <<-EOM
  Only relevant when the storage_type is "gp2".

  What percentage of burst balance can be left before a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "burst_balance_vlow_threshold" {
  type        = number
  default     = 30
  description = <<-EOM
  Only relevant when the storage_type is "gp2".

  What percentage of burst balance can be left before a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "read_latency_high_threshold" {
  type        = number
  default     = 5
  description = <<-EOM
  How many milliseconds can disk read operations take before a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "read_latency_vhigh_threshold" {
  type        = number
  default     = 10
  description = <<-EOM
  How many milliseconds can disk read operations take before a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "write_latency_high_threshold" {
  type        = number
  default     = 5
  description = <<-EOM
  How many milliseconds can disk write operations take before a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "write_latency_vhigh_threshold" {
  type        = number
  default     = 10
  description = <<-EOM
  How many milliseconds can disk write operations take before a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "free_storage_space_percentage_low_threshold" {
  type        = number
  default     = 15
  description = <<-EOM
  What percentage of disk space can be left before a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "free_storage_space_percentage_vlow_threshold" {
  type        = number
  default     = 5
  description = <<-EOM
  What percentage of disk space can be left before a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "cpu_utilization_high_threshold" {
  type        = number
  default     = 70
  description = <<-EOM
  How much cpu can be consumed until a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "cpu_utilization_vhigh_threshold" {
  type        = number
  default     = 90
  description = <<-EOM
  How much cpu can be consumed until a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "replica_lag_high_threshold" {
  type        = number
  default     = 60
  description = <<-EOM
  Only relevant when the instance is replicating from another source.

  How far behind can replication be in seconds before a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "replica_lag_vhigh_threshold" {
  type        = number
  default     = 120
  description = <<-EOM
  Only relevant when the instance is replicating from another source.

  How far behind can replication be in seconds before a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "replication_fault" {
  type        = bool
  default     = true
  description = <<-EOM
  Only relevant when the instance is replicating from another source.

  Should a high priority alarm be triggered when replication fails? Set to false to disable.
  EOM
}

variable "cpu_credit_balance_low_threshold" {
  type        = number
  default     = 100
  description = <<-EOM
  Only relevant when the instance class uses burstable cpu.

  How many CPU credits can be left before a low priority alert is triggered? Set to null to disable.
  EOM
}

variable "cpu_credit_balance_vlow_threshold" {
  type        = number
  default     = 29
  description = <<-EOM
  Only relevant when the instance class uses burstable cpu.

  How many CPU credits can be left before a high priority alert is triggered? Set to null to disable.
  EOM
}

variable "custom_alarms" {
  description = <<-EOT
    Custom CloudWatch alarms for additional RDS metrics.

    Threshold naming indicates direction:
    - high_threshold/vhigh_threshold: Alarm when metric is ABOVE threshold
    - low_threshold/vlow_threshold: Alarm when metric is BELOW threshold

    Priority levels:
    - high_threshold/low_threshold: Low priority (warning) → uses low_priority_alarm SNS topic
    - vhigh_threshold/vlow_threshold: High priority (critical) → uses high_priority_alarm SNS topic

    You can set both high AND low thresholds on the same metric to detect both extremes.

    Example - Detect database connection issues (too high OR too low):
      custom_alarms = {
        "connection_health" = {
          metric_name     = "DatabaseConnections"
          high_threshold  = 1000  # Warning when too many connections
          vhigh_threshold = 1500  # Critical when too many connections
          low_threshold   = 20    # Warning when too few connections
          vlow_threshold  = 10    # Critical when too few connections
          unit            = " connections"
        }

        "network_activity" = {
          metric_name    = "NetworkReceiveThroughput"
          vlow_threshold = 300000  # Only alarm on low throughput
          unit           = " bytes/sec"
        }
      }

    All metrics use the AWS/RDS namespace and DBInstanceIdentifier dimension automatically.
  EOT

  type = map(object({
    # Required
    metric_name = string

    # Thresholds (at least one required, can mix high and low)
    high_threshold  = optional(number)  # Low priority: alarm when metric > threshold
    vhigh_threshold = optional(number)  # High priority: alarm when metric > threshold
    low_threshold   = optional(number)  # Low priority: alarm when metric < threshold
    vlow_threshold  = optional(number)  # High priority: alarm when metric < threshold

    # Optional tuning
    statistic          = optional(string, "Average")  # Average, Sum, Maximum, Minimum, SampleCount
    period             = optional(number, 300)        # Evaluation period in seconds
    evaluation_periods = optional(number, 1)          # Number of periods before alarming

    # Optional display
    description = optional(string)  # Human-readable metric name (auto-generated if not provided)
    unit        = optional(string, "")  # Unit suffix for alarm description (e.g., "ms", "%", " connections")
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, v in var.custom_alarms : (
        v.high_threshold != null || v.vhigh_threshold != null ||
        v.low_threshold != null || v.vlow_threshold != null
      )
    ])
    error_message = "Each custom alarm must have at least one threshold set (high_threshold, vhigh_threshold, low_threshold, or vlow_threshold)."
  }
}

variable "tags" {
  type    = map(any)
  default = {}
}
