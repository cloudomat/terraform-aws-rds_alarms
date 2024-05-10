mock_provider "aws" {}

variables {
  db_instance = {
    identifier        = "test"
    instance_class    = "db.m6i.2xlarge",
    allocated_storage = 1000
    storage_type      = "gp3"
    iops              = 12000
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

run "no_alarms" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 0
    error_message = <<-EOM
    Unexpected alarms were created.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}, expected none.
    EOM
  }
}

run "alarms" {
  variables {
    cpu_utilization_high_threshold               = 10
    cpu_utilization_vhigh_threshold              = 20
    free_storage_space_percentage_low_threshold  = 20
    free_storage_space_percentage_vlow_threshold = 10
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 4
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_name == "RDS ${var.db_instance.identifier} CPU Utilization High"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_name} expected RDS ${var.db_instance.identifier} CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_name == "RDS ${var.db_instance.identifier} CPU Utilization Very High"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_name} expected RDS ${var.db_instance.identifier} Very CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_description == "${var.db_instance.identifier} CPU Utilization is above ${var.cpu_utilization_high_threshold}%"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_description} expected ${var.db_instance.identifier} CPU Utilization is above ${var.cpu_utilization_high_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_description == "${var.db_instance.identifier} CPU Utilization is above ${var.cpu_utilization_vhigh_threshold}%"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_description} expected ${var.db_instance.identifier} CPU Utilization is above ${var.cpu_utilization_vhigh_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold == var.cpu_utilization_high_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].threshold}, expected ${var.cpu_utilization_high_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold == var.cpu_utilization_vhigh_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].threshold}, expected ${var.cpu_utilization_vhigh_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_cpu_utilization"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_cpu_utilization"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  # Free Storage Space (testing directionality = low)
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].alarm_name == "RDS ${var.db_instance.identifier} Free Storage Space Low"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].alarm_name} expected RDS ${var.db_instance.identifier} Free Storage Space Low
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].alarm_name == "RDS ${var.db_instance.identifier} Free Storage Space Very Low"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].alarm_name} expected RDS ${var.db_instance.identifier} Free Storage Space Very Low
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].alarm_description == "${var.db_instance.identifier} Free Storage Space is below ${var.free_storage_space_percentage_low_threshold}%"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].alarm_description} expected ${var.db_instance.identifier} Free Storage Space is below ${var.free_storage_space_percentage_low_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].alarm_description == "${var.db_instance.identifier} Free Storage Space is below ${var.free_storage_space_percentage_vlow_threshold}%"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].alarm_description} expected ${var.db_instance.identifier} Free Storage Space is below ${var.free_storage_space_percentage_vlow_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].threshold == (200 * 1024 * 1024 * 1024)
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].threshold}, expected 200
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].threshold == (100 * 1024 * 1024 * 1024)
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].threshold}, expected 100
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_free_storage_space"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_free_storage_space"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }
}

run "replicate_alarms" {
  variables {
    replica_lag_high_threshold  = 10
    replica_lag_vhigh_threshold = 20
    db_instance = {
      identifier          = "test-read"
      instance_class      = "db.m6i.2xlarge",
      storage_type        = "gp3"
      replicate_source_db = "test"
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 3
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].alarm_name == "RDS ${var.db_instance.identifier} Replica Lag High"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].alarm_name} expected RDS ${var.db_instance.identifier} Replica Lag High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].alarm_name == "RDS ${var.db_instance.identifier} Replica Lag Very High"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].alarm_name} expected RDS ${var.db_instance.identifier} Very Replica Lag High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].alarm_description == "${var.db_instance.identifier} Replica Lag is above ${var.replica_lag_high_threshold} seconds"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].alarm_description} expected ${var.db_instance.identifier} Replica Lag is above ${var.replica_lag_high_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].alarm_description == "${var.db_instance.identifier} Replica Lag is above ${var.replica_lag_vhigh_threshold} seconds"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].alarm_description} expected ${var.db_instance.identifier} Replica Lag is above ${var.replica_lag_vhigh_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].threshold == var.replica_lag_high_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].threshold}, expected ${var.replica_lag_high_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].threshold == var.replica_lag_vhigh_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].threshold}, expected ${var.replica_lag_vhigh_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_replica_lag"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_replica_lag"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  # Replica Fault
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].alarm_name == "RDS ${var.db_instance.identifier} Replication Fault"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].alarm_name} expected RDS ${var.db_instance.identifier} Replication Fault
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].alarm_description == "${var.db_instance.identifier} has ceased replicating from the primary DB"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].alarm_description} expected ${var.db_instance.identifier} has ceased replicating from the primary DB
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].threshold == -1
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].threshold}, expected -1
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].period == 60
    error_message = <<-EOM
    Incorrect high priority alarm period.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].period}, expected 60
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_replica_fault"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }
}

run "burstable_instance_alarms" {
  variables {
    cpu_credit_balance_low_threshold  = 60
    cpu_credit_balance_vlow_threshold = 30
    db_instance = {
      identifier     = "test"
      instance_class = "db.t3.small",
      storage_type   = "gp3"
    }
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 2
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].alarm_name == "RDS ${var.db_instance.identifier} CPU Credit Balance Low"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].alarm_name} expected RDS ${var.db_instance.identifier} CPU Credit Balance Low
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].alarm_name == "RDS ${var.db_instance.identifier} CPU Credit Balance Very Low"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].alarm_name} expected RDS ${var.db_instance.identifier} CPU Credit Balance Very Low
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].alarm_description == "${var.db_instance.identifier} CPU Credit Balance is below ${var.cpu_credit_balance_low_threshold}"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].alarm_description} expected ${var.db_instance.identifier} CPU Credit Balance is below ${var.cpu_credit_balance_low_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].alarm_description == "${var.db_instance.identifier} CPU Credit Balance is below ${var.cpu_credit_balance_vlow_threshold}"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].alarm_description} expected ${var.db_instance.identifier} CPU Credit Balance is below ${var.cpu_credit_balance_vlow_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].threshold == var.cpu_credit_balance_low_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].threshold}, expected ${var.cpu_credit_balance_low_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].threshold == var.cpu_credit_balance_vlow_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].threshold}, expected ${var.cpu_credit_balance_vlow_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["low_cpu_credit_balance"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["high_cpu_credit_balance"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }
}
