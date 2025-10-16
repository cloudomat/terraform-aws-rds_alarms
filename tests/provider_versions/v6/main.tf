# Test fixture for AWS Provider v6.x compatibility
# This configuration verifies that the module works correctly with AWS Provider 6.x

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Mock provider for testing - no real AWS credentials needed
provider "aws" {
  region = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Mock endpoints to avoid actual AWS API calls
  endpoints {
    cloudwatch = "http://localhost:4566"
    sns        = "http://localhost:4566"
  }
}

# Call the module with a typical configuration
module "rds_alarms" {
  source = "../../.."

  db_instance = {
    identifier        = "test-instance"
    instance_class    = "db.m6i.2xlarge"
    allocated_storage = 1000
    storage_type      = "gp3"
  }

  low_priority_alarm  = ["arn:aws:sns:us-east-1:111111111111:alerts_low"]
  high_priority_alarm = ["arn:aws:sns:us-east-1:111111111111:alerts_high"]

  # Enable a few alarms to verify they're created correctly
  cpu_utilization_high_threshold               = 80
  cpu_utilization_vhigh_threshold              = 90
  free_storage_space_percentage_low_threshold  = 20
  free_storage_space_percentage_vlow_threshold = 10
}

# No outputs needed - we just verify that the plan succeeds
