# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Terraform module for creating CloudWatch alarms for AWS RDS instances. It supports dual-threshold alarming: low priority (early warning) and high priority (immediate attention required) for various RDS metrics.

## Requirements

- Terraform >= 1.5.0
- AWS Provider >= 4, < 6

## Testing

Run Terraform tests:
```bash
terraform test
```

The test file is located at `tests/alarm_selection.tftest.hcl` and uses Terraform's native testing framework with mock AWS provider.

## Git Workflow

When creating commits in this repository, the commit message should include the **COMPLETE** set of user prompts that led to the changes. This provides full context for the changes being committed.

## Architecture

### Conditional Alarm Logic (main.tf:26-131)

The module uses a sophisticated conditional system in `locals` to determine which alarms to create based on instance characteristics:

- **always_on**: Metrics monitored for all instances (CPU, read/write latency)
- **only_replicate**: Metrics only for read replicas (replica lag, replication fault detection)
- **only_burstable**: Metrics for burstable instance types (db.t* series - CPU credit balance)
- **only_known_storage**: Metrics requiring known storage size (free storage space)
- **only_burstable_storage**: Metrics for gp2 storage < 1TB (burst balance)

These are merged into `relevant_alarms` which is then split into low and high priority based on threshold configuration.

### Alarm Generation Pattern

The module generates alarms dynamically using `for_each` over the merged alarm map. Each metric can have:
- A low priority alarm (triggered by `*_high_threshold` variables)
- A high priority alarm (triggered by `*_vhigh_threshold` variables)

Setting a threshold variable to `null` disables that alarm level for that metric.

### Key Design Decisions

1. **Unit Conversions**: Some metrics require unit conversion:
   - Latency thresholds are specified in milliseconds but CloudWatch uses seconds (main.tf:42-59)
   - Free storage space uses percentage but CloudWatch measures bytes (main.tf:96-97)

2. **Directionality**: Each metric has a directionality ("high" or "low") determining whether to trigger when above or below threshold (main.tf:162)

3. **Alarm Naming**: Generated as "RDS {identifier} {metric} [Very] {High/Low}" (main.tf:136-148)

4. **Special Case - Replication Fault**: Uses threshold of -1 to detect when ReplicaLag metric stops reporting (main.tf:72-81)

### Variable Structure

The module takes a `db_instance` object (not individual variables) containing RDS instance properties from `data.aws_db_instance`. This design enables the module to introspect instance characteristics and conditionally create relevant alarms.

## Custom Alarms

The module supports user-defined custom alarms via the `custom_alarms` variable (variables.tf:170-236). This allows users to quickly add alarms for metrics not covered by the built-in alarms.

### Design

- **Threshold naming indicates direction**: `high_threshold`/`vhigh_threshold` alarm when metric > threshold, `low_threshold`/`vlow_threshold` alarm when metric < threshold
- **Bidirectional support**: Can set both high and low thresholds on the same metric (e.g., DatabaseConnections can alarm when too high OR too low)
- **Integration**: Custom alarms are transformed into the same internal structure as built-in alarms (main.tf:32-76) and flow through the same `aws_cloudwatch_metric_alarm.alarms` resource
- **Namespacing**: Custom alarm keys are prefixed with `custom_` internally to avoid collisions (e.g., `custom_connection_health_high`, `custom_connection_health_low`)
- **Description handling**: If `description` is not provided, the metric name is used as-is in alarm names/descriptions

### Custom Alarm Transformation Logic (main.tf:32-76)

The `custom_alarm_configs` local splits bidirectional alarms into separate high/low entries:
- High direction alarms: Created when `high_threshold` or `vhigh_threshold` is set
- Low direction alarms: Created when `low_threshold` or `vlow_threshold` is set
- Each direction creates up to 2 alarms (low priority + high priority)

These are merged into `relevant_alarms` (main.tf:172) before being split into `low_priority_alarms` and `high_priority_alarms`.

## Moved Blocks

Lines 174-247 contain `moved` blocks for backward compatibility from v0.1.0 to v0.2.0, mapping old individual alarm resources to the new dynamic alarm map.
