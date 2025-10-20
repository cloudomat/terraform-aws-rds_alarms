## 1.0.0-rc1

IMPROVEMENTS:

* Added examples directory with 5 real-world usage scenarios (minimal, replica-monitoring, performance-monitoring, burstable-instance, complete)
* Added comprehensive built-in metrics documentation covering all 11 monitored metrics
* Added alarm selection flowchart visualizing instance-aware alarm creation logic
* Added upgrade guide documenting migration from v0.2.1 to v1.0

NOTES:

* This is a release candidate for v1.0.0
* No code changes since v0.4.0 - documentation and examples only
* Module now monitors 11 RDS CloudWatch metrics with 100% test coverage
* Full backward compatibility maintained with v0.2.1

## 0.4.0

FEATURES:

* **Extended Statistics Support**: Custom alarms now support percentile-based metrics
  * New `extended_statistic` field enables p50, p95, p99, p100, and other percentiles
  * Ideal for performance monitoring use cases (e.g., p99 latency tracking)
  * CloudWatch enforces exclusive use of either `statistic` or `extended_statistic`
  * Validation prevents conflicting configuration
* **treat_missing_data Configuration**: Custom alarms can now control behavior during missing data
  * New `treat_missing_data` field supports: "missing", "ignore", "breaching", "notBreaching"
  * Defaults to "missing" for backward compatibility
  * Useful during maintenance windows or intermittent metric reporting
  * Validation ensures only valid CloudWatch values are accepted

NOTES:

* All new fields are optional with backward-compatible defaults
* No breaking changes from v0.3.0

## 0.3.0

FEATURES:

* **Custom Alarms Support**: New `custom_alarms` variable allows defining alarms for any RDS CloudWatch metric
  * Supports bidirectional alarming (alarm on both high AND low values for the same metric)
  * Useful for detecting both overload and unavailability scenarios (e.g., very high or very low connection counts)
  * Each direction supports dual-priority thresholds (warning + critical)
  * See README.md for usage examples and full API documentation
* **New Built-in Metrics**: Added support for three additional RDS CloudWatch metrics:
  * `DiskQueueDepth` - Detects I/O bottlenecks and storage performance issues
  * `FreeableMemory` - Detects memory pressure and potential OOM conditions
  * `SwapUsage` - Detects memory swapping issues and performance degradation
* Module now monitors 11 RDS CloudWatch metrics (up from 8)

IMPROVEMENTS:

* Extended AWS Provider support from v4-v5 to v4-v6 (now supports AWS Provider 4.x, 5.x, and 6.x)
* Added comprehensive multi-version testing infrastructure for AWS provider compatibility

NOTES:

* All new threshold variables default to `null` for full backward compatibility
* No breaking changes from v0.2.1

## 0.2.1

BUG FIXES:

* Fixes free storage space alarms.

## 0.2.0

BREAKING CHANGES:

* Requires terraform >= 1.5.0
* Takes a db_instance variable instead of individual variables for each configuration option.
* Read and write latency thresholds are now given in milliseconds
* Storage space threshold variables have been renamed and are now given in whole numbers (15 instead of 0.15 for 15%)

## 0.1.0

Initial release
