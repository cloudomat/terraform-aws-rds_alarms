variable "aws_region" {
  description = "AWS region where your RDS read replica is located"
  type        = string
  default     = "us-east-1"
}

variable "db_instance_identifier" {
  description = "The identifier of your RDS read replica instance"
  type        = string
}

variable "low_priority_sns_topic" {
  description = "ARN of SNS topic for low priority (warning) alerts"
  type        = string
}

variable "high_priority_sns_topic" {
  description = "ARN of SNS topic for high priority (critical) alerts"
  type        = string
}
