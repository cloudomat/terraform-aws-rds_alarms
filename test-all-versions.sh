#!/bin/bash
# Test script for verifying AWS provider version compatibility
# Tests both the mock provider tests and real provider version tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track results
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Terraform AWS RDS Alarms Module${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to run a test and track results
run_test() {
    local test_name=$1
    shift
    local test_command=("$@")

    echo -e "${YELLOW}Running: ${test_name}${NC}"
    echo "Command: ${test_command[*]}"
    echo ""

    if "${test_command[@]}"; then
        echo -e "${GREEN}✓ PASSED: ${test_name}${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAILED: ${test_name}${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
    fi
    echo ""
}

# Function to test a specific provider version
test_provider_version() {
    local version=$1
    local version_dir="tests/provider_versions/$version"

    echo -e "${BLUE}Testing AWS Provider ${version}...${NC}"
    echo ""

    # Clean up any previous state
    rm -rf "$version_dir/.terraform" "$version_dir/.terraform.lock.hcl" "$version_dir/terraform.tfstate" "$version_dir/terraform.tfstate.backup" 2>/dev/null || true

    # Initialize
    (cd "$version_dir" && run_test "Init AWS Provider $version" terraform init -upgrade)

    # Validate
    (cd "$version_dir" && run_test "Validate with AWS Provider $version" terraform validate)

    # Plan (with fake AWS credentials)
    (cd "$version_dir" && \
     AWS_ACCESS_KEY_ID=test \
     AWS_SECRET_ACCESS_KEY=test \
     AWS_REGION=us-east-1 \
     run_test "Plan with AWS Provider $version" terraform plan -out=tfplan)

    # Clean up plan file
    rm -f "$version_dir/tfplan" 2>/dev/null || true

    echo ""
}

# 1. Run standard Terraform tests (with mock providers)
echo -e "${BLUE}Step 1: Running standard Terraform tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

run_test "Terraform test" terraform test

echo ""

# 2. Test AWS Provider 4.x
echo -e "${BLUE}Step 2: Testing AWS Provider 4.x Compatibility${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

test_provider_version "v4"

# 3. Test AWS Provider 5.x
echo -e "${BLUE}Step 3: Testing AWS Provider 5.x Compatibility${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

test_provider_version "v5"

# 4. Test AWS Provider 6.x
echo -e "${BLUE}Step 4: Testing AWS Provider 6.x Compatibility${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

test_provider_version "v6"

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed Tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
    echo ""
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    exit 0
fi
