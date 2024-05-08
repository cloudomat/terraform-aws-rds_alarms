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
  type    = number
  default = 70
}

variable "burst_balance_vlow_threshold" {
  type    = number
  default = 30
}

variable "read_latency_high_threshold" {
  type    = number
  default = 5
}

variable "read_latency_vhigh_threshold" {
  type    = number
  default = 10
}

variable "write_latency_high_threshold" {
  type    = number
  default = 5
}

variable "write_latency_vhigh_threshold" {
  type    = number
  default = 10
}

variable "free_storage_space_percentage_low_threshold" {
  type    = number
  default = 15
}

variable "free_storage_space_percentage_vlow_threshold" {
  type    = number
  default = 5
}

variable "cpu_utilization_high_threshold" {
  type    = number
  default = 70
}

variable "cpu_utilization_vhigh_threshold" {
  type    = number
  default = 90
}

variable "replica_lag_high_threshold" {
  type    = number
  default = 60
}

variable "replica_lag_vhigh_threshold" {
  type    = number
  default = 120
}

variable "replication_fault" {
  type    = bool
  default = true
}

variable "cpu_credit_balance_low_threshold" {
  type    = number
  default = 100
}

variable "cpu_credit_balance_vlow_threshold" {
  type    = number
  default = 29
}

variable "tags" {
  type    = map(any)
  default = {}
}
