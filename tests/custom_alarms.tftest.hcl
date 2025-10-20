mock_provider "aws" {}

variables {
  db_instance = {
    identifier     = "test"
    instance_class = "db.m6i.2xlarge"
    storage_type   = "gp3"
  }
  low_priority_alarm                           = ["arn:aws:sns:us-east-1:111111111111:alerts_low"]
  high_priority_alarm                          = ["arn:aws:sns:us-east-1:111111111111:alerts_high"]
  cpu_utilization_high_threshold               = null
  cpu_utilization_vhigh_threshold              = null
  free_storage_space_percentage_low_threshold  = null
  free_storage_space_percentage_vlow_threshold = null
  read_latency_high_threshold                  = null
  read_latency_vhigh_threshold                 = null
  write_latency_high_threshold                 = null
  write_latency_vhigh_threshold                = null
}

# Test 1: No custom alarms (baseline - verify backward compatibility)
run "no_custom_alarms" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 0
    error_message = <<-EOM
    Expected no alarms when no thresholds set.
    Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))} alarms: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }
}

# Test 2: Simple unidirectional custom alarm (low direction)
run "simple_low_direction_alarm" {
  variables {
    custom_alarms = {
      "connection_availability" = {
        metric_name    = "DatabaseConnections"
        low_threshold  = 20
        vlow_threshold = 10
        description    = "Database Connections"
        unit           = " connections"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = <<-EOM
    Expected 2 alarms for bidirectional thresholds.
    Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))} alarms: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  # Low priority alarm (low_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "low_custom_connection_availability_low")
    error_message = "Expected alarm with key 'low_custom_connection_availability_low' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].alarm_name == "RDS ${var.db_instance.identifier} Database Connections Low"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Expected: RDS ${var.db_instance.identifier} Database Connections Low
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].alarm_name, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].alarm_description == "${var.db_instance.identifier} Database Connections is below 20 connections"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Expected: ${var.db_instance.identifier} Database Connections is below 20 connections
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].alarm_description, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].threshold == 20
    error_message = "Expected threshold 20, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].threshold, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].comparison_operator == "LessThanOrEqualToThreshold"
    error_message = "Expected LessThanOrEqualToThreshold, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].comparison_operator, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].metric_name == "DatabaseConnections"
    error_message = "Expected metric_name DatabaseConnections, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].metric_name, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].namespace == "AWS/RDS"
    error_message = "Expected namespace AWS/RDS, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].namespace, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].statistic == "Average"
    error_message = "Expected default statistic Average, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].statistic, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].period == 300
    error_message = "Expected default period 300, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].period, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].evaluation_periods == 1
    error_message = "Expected default evaluation_periods 1, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].evaluation_periods, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].alarm_actions == toset(var.low_priority_alarm)
    error_message = "Expected low priority SNS topic, got ${try(join(", ", aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].alarm_actions), "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].dimensions == tomap({ DBInstanceIdentifier = var.db_instance.identifier })
    error_message = "Expected DBInstanceIdentifier dimension, got ${try(jsonencode(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_availability_low"].dimensions), "ALARM NOT FOUND")}"
  }

  # High priority alarm (vlow_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "high_custom_connection_availability_low")
    error_message = "Expected alarm with key 'high_custom_connection_availability_low' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].alarm_name == "RDS ${var.db_instance.identifier} Database Connections Very Low"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Expected: RDS ${var.db_instance.identifier} Database Connections Very Low
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].alarm_name, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].alarm_description == "${var.db_instance.identifier} Database Connections is below 10 connections"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Expected: ${var.db_instance.identifier} Database Connections is below 10 connections
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].alarm_description, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].threshold == 10
    error_message = "Expected threshold 10, got ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].threshold, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].comparison_operator == "LessThanOrEqualToThreshold"
    error_message = "Expected LessThanOrEqualToThreshold, got ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].comparison_operator, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].alarm_actions == toset(var.high_priority_alarm)
    error_message = "Expected high priority SNS topic, got ${try(join(", ", aws_cloudwatch_metric_alarm.alarms["high_custom_connection_availability_low"].alarm_actions), "ALARM NOT FOUND")}"
  }
}

# Test 3: Simple unidirectional custom alarm (high direction)
run "simple_high_direction_alarm" {
  variables {
    custom_alarms = {
      "query_rate" = {
        metric_name     = "Queries"
        high_threshold  = 1000
        vhigh_threshold = 2000
        statistic       = "Sum"
        period          = 60
        unit            = " queries/min"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = <<-EOM
    Expected 2 alarms for high direction thresholds.
    Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))} alarms: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  # Low priority alarm (high_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "low_custom_query_rate_high")
    error_message = "Expected alarm with key 'low_custom_query_rate_high' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].alarm_name == "RDS ${var.db_instance.identifier} Queries High"
    error_message = <<-EOM
    Incorrect alarm name.
    Expected: RDS ${var.db_instance.identifier} Queries High
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].alarm_name, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].alarm_description == "${var.db_instance.identifier} Queries is above 1000 queries/min"
    error_message = <<-EOM
    Incorrect alarm description.
    Expected: ${var.db_instance.identifier} Queries is above 1000 queries/min
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].alarm_description, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].threshold == 1000
    error_message = "Expected threshold 1000, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].threshold, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].comparison_operator == "GreaterThanOrEqualToThreshold"
    error_message = "Expected GreaterThanOrEqualToThreshold, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].comparison_operator, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].statistic == "Sum"
    error_message = "Expected statistic Sum, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].statistic, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].period == 60
    error_message = "Expected period 60, got ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].period, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_query_rate_high"].alarm_actions == toset(var.low_priority_alarm)
    error_message = "Expected low priority SNS topic"
  }

  # High priority alarm (vhigh_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "high_custom_query_rate_high")
    error_message = "Expected alarm with key 'high_custom_query_rate_high' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_query_rate_high"].alarm_name == "RDS ${var.db_instance.identifier} Queries Very High"
    error_message = <<-EOM
    Incorrect alarm name.
    Expected: RDS ${var.db_instance.identifier} Queries Very High
    Got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_query_rate_high"].alarm_name, "ALARM NOT FOUND")}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_query_rate_high"].threshold == 2000
    error_message = "Expected threshold 2000, got ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_query_rate_high"].threshold, "ALARM NOT FOUND")}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_query_rate_high"].alarm_actions == toset(var.high_priority_alarm)
    error_message = "Expected high priority SNS topic"
  }
}

# Test 4: Bidirectional alarm (both high AND low thresholds on same metric)
run "bidirectional_alarm" {
  variables {
    custom_alarms = {
      "connection_health" = {
        metric_name     = "DatabaseConnections"
        high_threshold  = 1000  # Too many connections (warning)
        vhigh_threshold = 1500  # Too many connections (critical)
        low_threshold   = 20    # Too few connections (warning)
        vlow_threshold  = 10    # Too few connections (critical)
        unit            = " connections"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 4
    error_message = <<-EOM
    Expected 4 alarms for bidirectional thresholds (2 high + 2 low).
    Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))} alarms: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  # High direction - low priority (high_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "low_custom_connection_health_high")
    error_message = "Expected alarm 'low_custom_connection_health_high' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_high"].alarm_name == "RDS ${var.db_instance.identifier} DatabaseConnections High"
    error_message = "Incorrect alarm name for high direction warning"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_high"].threshold == 1000
    error_message = "Expected threshold 1000, got ${aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_high"].threshold}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_high"].comparison_operator == "GreaterThanOrEqualToThreshold"
    error_message = "Expected GreaterThanOrEqualToThreshold for high direction"
  }

  # High direction - high priority (vhigh_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "high_custom_connection_health_high")
    error_message = "Expected alarm 'high_custom_connection_health_high' not found"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_health_high"].alarm_name == "RDS ${var.db_instance.identifier} DatabaseConnections Very High"
    error_message = "Incorrect alarm name for high direction critical"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_health_high"].threshold == 1500
    error_message = "Expected threshold 1500"
  }

  # Low direction - low priority (low_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "low_custom_connection_health_low")
    error_message = "Expected alarm 'low_custom_connection_health_low' not found"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_low"].alarm_name == "RDS ${var.db_instance.identifier} DatabaseConnections Low"
    error_message = "Incorrect alarm name for low direction warning"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_low"].threshold == 20
    error_message = "Expected threshold 20"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_health_low"].comparison_operator == "LessThanOrEqualToThreshold"
    error_message = "Expected LessThanOrEqualToThreshold for low direction"
  }

  # Low direction - high priority (vlow_threshold)
  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "high_custom_connection_health_low")
    error_message = "Expected alarm 'high_custom_connection_health_low' not found"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_health_low"].alarm_name == "RDS ${var.db_instance.identifier} DatabaseConnections Very Low"
    error_message = "Incorrect alarm name for low direction critical"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_health_low"].threshold == 10
    error_message = "Expected threshold 10"
  }
}

# Test 5: Single threshold only (only vlow_threshold)
run "single_threshold_only" {
  variables {
    custom_alarms = {
      "network_throughput" = {
        metric_name    = "NetworkReceiveThroughput"
        vlow_threshold = 300000
        unit           = " bytes/sec"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 1
    error_message = <<-EOM
    Expected 1 alarm for single threshold.
    Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))} alarms: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "high_custom_network_throughput_low")
    error_message = "Expected alarm 'high_custom_network_throughput_low' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_network_throughput_low"].alarm_name == "RDS ${var.db_instance.identifier} NetworkReceiveThroughput Very Low"
    error_message = "Incorrect alarm name"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_network_throughput_low"].threshold == 300000
    error_message = "Expected threshold 300000"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_network_throughput_low"].alarm_actions == toset(var.high_priority_alarm)
    error_message = "Expected high priority SNS topic"
  }
}

# Test 6: Custom alarms with built-in alarms
run "custom_with_builtin_alarms" {
  variables {
    cpu_utilization_high_threshold = 80

    custom_alarms = {
      "low_connections" = {
        metric_name    = "DatabaseConnections"
        vlow_threshold = 10
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = <<-EOM
    Expected 2 alarms (1 built-in + 1 custom).
    Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))} alarms: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "low_cpu_utilization")
    error_message = "Expected built-in alarm 'low_cpu_utilization' not found"
  }

  assert {
    condition     = contains(keys(aws_cloudwatch_metric_alarm.alarms), "high_custom_low_connections_low")
    error_message = "Expected custom alarm 'high_custom_low_connections_low' not found. Available: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }
}

# Test 7: Description handling (explicit vs metric name)
run "description_handling" {
  variables {
    custom_alarms = {
      "test1" = {
        metric_name     = "DiskQueueDepth"
        vhigh_threshold = 64
        # No description provided - should use metric name as-is
      }

      "test2" = {
        metric_name    = "CustomMetricName"
        description    = "Custom Description"
        vhigh_threshold = 100
        # Explicit description provided
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = "Expected 2 alarms for description test"
  }

  # Test metric name used as-is when no description
  assert {
    condition     = length(regexall("DiskQueueDepth", aws_cloudwatch_metric_alarm.alarms["high_custom_test1_high"].alarm_description)) > 0
    error_message = "Expected metric name 'DiskQueueDepth' in alarm description, got: ${aws_cloudwatch_metric_alarm.alarms["high_custom_test1_high"].alarm_description}"
  }

  # Test explicit description
  assert {
    condition     = length(regexall("Custom Description", aws_cloudwatch_metric_alarm.alarms["high_custom_test2_high"].alarm_description)) > 0
    error_message = "Expected 'Custom Description' in alarm description, got: ${aws_cloudwatch_metric_alarm.alarms["high_custom_test2_high"].alarm_description}"
  }
}

# Test 8: Extended statistics support (p99 latency tracking)
run "extended_statistic_support" {
  variables {
    custom_alarms = {
      "p99_read_latency" = {
        metric_name        = "ReadLatency"
        extended_statistic = "p99"
        vhigh_threshold    = 0.050  # 50ms in seconds
        description        = "p99 Read Latency"
        unit               = "s"
        period             = 60
      }
      "p95_write_latency" = {
        metric_name        = "WriteLatency"
        extended_statistic = "p95"
        high_threshold     = 0.030  # 30ms in seconds
        description        = "p95 Write Latency"
        unit               = "s"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = "Expected 2 alarms for extended statistic test. Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))}: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  # Verify extended_statistic is set for p99 alarm
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].extended_statistic == "p99"
    error_message = "Expected extended_statistic to be 'p99', got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].extended_statistic, "NOT SET")}"
  }

  # Verify statistic is null when extended_statistic is set
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].statistic == null
    error_message = "Expected statistic to be null when extended_statistic is set"
  }

  # Verify extended_statistic is set for p95 alarm
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_p95_write_latency_high"].extended_statistic == "p95"
    error_message = "Expected extended_statistic to be 'p95', got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_p95_write_latency_high"].extended_statistic, "NOT SET")}"
  }

  # Verify statistic is null when extended_statistic is set
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_p95_write_latency_high"].statistic == null
    error_message = "Expected statistic to be null when extended_statistic is set"
  }

  # Verify threshold value is correct
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].threshold == 0.050
    error_message = "Expected threshold to be 0.050, got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].threshold, "NOT SET")}"
  }

  # Verify period is correctly set
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].period == 60
    error_message = "Expected period to be 60, got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_p99_read_latency_high"].period, "NOT SET")}"
  }
}

# Test 9: treat_missing_data support
run "treat_missing_data_support" {
  variables {
    custom_alarms = {
      "connection_with_ignore" = {
        metric_name        = "DatabaseConnections"
        low_threshold      = 10
        description        = "Connections (ignore missing)"
        treat_missing_data = "ignore"
      }
      "connection_with_notBreaching" = {
        metric_name        = "DatabaseConnections"
        high_threshold     = 1000
        description        = "Connections (notBreaching)"
        treat_missing_data = "notBreaching"
      }
      "connection_with_breaching" = {
        metric_name        = "DatabaseConnections"
        vhigh_threshold    = 1500
        description        = "Connections (breaching)"
        treat_missing_data = "breaching"
      }
      "connection_with_default" = {
        metric_name    = "DatabaseConnections"
        vlow_threshold = 5
        description    = "Connections (default missing)"
        # treat_missing_data not set - should default to "missing"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 4
    error_message = "Expected 4 alarms for treat_missing_data test. Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))}: ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  # Verify treat_missing_data = "ignore"
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_with_ignore_low"].treat_missing_data == "ignore"
    error_message = "Expected treat_missing_data to be 'ignore', got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_with_ignore_low"].treat_missing_data, "NOT SET")}"
  }

  # Verify treat_missing_data = "notBreaching"
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_custom_connection_with_notBreaching_high"].treat_missing_data == "notBreaching"
    error_message = "Expected treat_missing_data to be 'notBreaching', got: ${try(aws_cloudwatch_metric_alarm.alarms["low_custom_connection_with_notBreaching_high"].treat_missing_data, "NOT SET")}"
  }

  # Verify treat_missing_data = "breaching"
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_with_breaching_high"].treat_missing_data == "breaching"
    error_message = "Expected treat_missing_data to be 'breaching', got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_connection_with_breaching_high"].treat_missing_data, "NOT SET")}"
  }

  # Verify default treat_missing_data = "missing"
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_connection_with_default_low"].treat_missing_data == "missing"
    error_message = "Expected treat_missing_data to default to 'missing', got: ${try(aws_cloudwatch_metric_alarm.alarms["high_custom_connection_with_default_low"].treat_missing_data, "NOT SET")}"
  }
}

# Test 10: Combined extended_statistic and treat_missing_data
run "combined_extended_stat_and_treat_missing" {
  variables {
    custom_alarms = {
      "p99_cpu_notBreaching" = {
        metric_name        = "CPUUtilization"
        extended_statistic = "p99"
        vhigh_threshold    = 95
        description        = "p99 CPU Utilization"
        unit               = "%"
        treat_missing_data = "notBreaching"
      }
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 1
    error_message = "Expected 1 alarm. Got ${length(keys(aws_cloudwatch_metric_alarm.alarms))}"
  }

  # Verify extended_statistic is set
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_cpu_notBreaching_high"].extended_statistic == "p99"
    error_message = "Expected extended_statistic to be 'p99'"
  }

  # Verify treat_missing_data is set
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_cpu_notBreaching_high"].treat_missing_data == "notBreaching"
    error_message = "Expected treat_missing_data to be 'notBreaching'"
  }

  # Verify statistic is null
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_custom_p99_cpu_notBreaching_high"].statistic == null
    error_message = "Expected statistic to be null when extended_statistic is set"
  }
}
