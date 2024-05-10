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
