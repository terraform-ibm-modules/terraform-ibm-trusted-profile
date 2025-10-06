#!/bin/bash
set -e

echo "Testing dynamic assignment example for for_each dependency issues..."

# Change to the dynamic assignment example directory
cd "$(dirname "$0")/examples/dynamic-assignment"

# Initialize terraform
echo "Running terraform init..."
terraform init > /dev/null 2>&1

# Test that plan generation works (this would fail with for_each dependency issues)
# We expect this to fail due to authentication, but NOT due to for_each dependency issues
echo "Testing terraform plan (expecting auth error, not dependency error)..."
if terraform plan -var="ibmcloud_api_key=dummy" 2>&1 | grep -q "known only after apply"; then
    echo "❌ FAILED: Found 'known only after apply' error - for_each dependency issue still exists"
    exit 1
elif terraform plan -var="ibmcloud_api_key=dummy" 2>&1 | grep -q "Invalid for each argument"; then
    echo "❌ FAILED: Found 'Invalid for each argument' error - for_each dependency issue still exists"
    exit 1  
elif terraform plan -var="ibmcloud_api_key=dummy" 2>&1 | grep -q "API key could not be found"; then
    echo "✅ PASSED: Plan failed with expected auth error, no for_each dependency issues detected"
    exit 0
else
    echo "❌ FAILED: Unexpected terraform plan result"
    exit 1
fi