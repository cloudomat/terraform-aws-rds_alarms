# Provider Version Compatibility Tests

This directory contains test configurations to verify that the terraform-aws-rds_alarms module works correctly with different versions of the AWS provider.

## Structure

```
provider_versions/
├── v4/
│   └── main.tf          # Test configuration for AWS Provider 4.x
└── v5/
    └── main.tf          # Test configuration for AWS Provider 5.x
```

## Running Tests Locally

To run tests for all provider versions:

```bash
./test-all-versions.sh
```

This script will:
1. Run standard Terraform tests (with mock providers)
2. Test compatibility with AWS Provider 4.x
3. Test compatibility with AWS Provider 5.x

## Test Approach

Each provider version directory contains a complete Terraform configuration that:
- Specifies the exact provider version to test
- Uses mock AWS endpoints (no real AWS credentials needed)
- Calls the module with a representative configuration
- Verifies that `terraform init`, `validate`, and `plan` complete successfully

## Adding New Provider Versions

To test a new provider version:

1. Create a new directory (e.g., `v6/`)
2. Copy `v5/main.tf` as a starting point
3. Update the `required_providers` version constraint
4. Update `test-all-versions.sh` to include the new version

## CI/CD

The test script is designed to work in CircleCI and other CI environments. See the root `.circleci/config.yml` for the CI configuration.
