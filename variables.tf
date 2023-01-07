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

variable "db_instance_identifier" {
  type        = string
  description = "The identifier of the database instance for alarming"
}

variable "low_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a low priority alarm"
}

variable "high_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a high priority alarm"
}

variable "allocated_storage" {
  type        = number
  description = "The size in GiB of disk space allocated to the instance"
}

variable "replicate_source_db" {
  type        = string
  description = "The replicate source db of the instance"
  default     = ""
}

variable "db_instance_class" {
  type        = string
  description = "The class of the db instance"
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
  default = 0.005
}

variable "read_latency_vhigh_threshold" {
  type    = number
  default = 0.01
}

variable "write_latency_high_threshold" {
  type    = number
  default = 0.005
}

variable "write_latency_vhigh_threshold" {
  type    = number
  default = 0.01
}

variable "fss_fraction_low_threshold" {
  type    = number
  default = 0.15
}

variable "fss_fraction_vlow_threshold" {
  type    = number
  default = 0.05
}

variable "fss_amount_critical_threshold" {
  type    = number
  default = 10
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

variable "cpu_credit_balance_low_threshold" {
  type    = number
  default = 100
}

variable "cpu_credit_balance_vlow_threshold" {
  type    = number
  default = 29
}

variable "tags" {
  type    = map
  default = {}
}
