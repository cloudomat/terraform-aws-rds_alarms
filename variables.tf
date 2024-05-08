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

variable "tags" {
  type    = map(any)
  default = {}
}
