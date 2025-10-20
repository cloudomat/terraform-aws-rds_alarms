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
