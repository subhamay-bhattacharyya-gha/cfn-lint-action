#!/bin/bash

# Test script to verify exit code handling implementation
echo "Testing CloudFormation Linter Action Exit Code Handling"
echo "======================================================="

# Test with valid template (should exit 0)
echo ""
echo "Test 1: Valid template (expecting exit code 0)"
echo "-----------------------------------------------"

# Simulate the action's exit code handling logic
TEMPLATE_PATH="test-template.yaml"
TEMPLATE_NAME=$(basename "$TEMPLATE_PATH")
FULL_TEMPLATE_PATH="$(pwd)/$TEMPLATE_PATH"

echo "Processing CloudFormation template: $TEMPLATE_NAME"

if [ ! -f "$FULL_TEMPLATE_PATH" ]; then
  echo "❌ Error: CloudFormation template not found at path: $FULL_TEMPLATE_PATH"
  exit 1
fi

# Run cfn-lint with error handling
set +e
LINT_OUTPUT=$(cfn-lint --format parseable "$FULL_TEMPLATE_PATH" 2>&1)
LINT_EXIT_CODE=$?
set -e

# Test our exit code mapping logic
echo ""
echo "=== CloudFormation Linting Summary ==="
echo "Template: $TEMPLATE_NAME"
echo "Exit Code: $LINT_EXIT_CODE"

case $LINT_EXIT_CODE in
  0)
    echo "Status: ✅ SUCCESS - No issues found"
    echo "Result: Template passed all CloudFormation linting checks"
    ;;
  2)
    echo "Status: ⚠️  WARNINGS - Template has warnings"
    echo "Result: Template has potential issues that should be reviewed"
    ;;
  4)
    echo "Status: ❌ ERRORS - Template has errors"
    echo "Result: Template has critical issues that must be fixed"
    ;;
  6)
    echo "Status: ❌ ERRORS + WARNINGS - Template has both errors and warnings"
    echo "Result: Template has critical issues and warnings that must be addressed"
    ;;
  8)
    echo "Status: ❌ INVALID CLI - Invalid command line arguments"
    echo "Result: cfn-lint was called with invalid parameters"
    ;;
  16)
    echo "Status: ❌ FATAL - Fatal errors occurred"
    echo "Result: cfn-lint encountered fatal errors during execution"
    ;;
  *)
    echo "Status: ❌ UNKNOWN - Unexpected exit code"
    echo "Result: cfn-lint returned an unexpected exit code: $LINT_EXIT_CODE"
    ;;
esac

if [ $LINT_EXIT_CODE -ne 0 ] && [ -n "$LINT_OUTPUT" ]; then
  echo ""
  echo "=== Detailed cfn-lint Output ==="
  echo "$LINT_OUTPUT"
fi

echo ""
echo "=== Exit Code Reference ==="
echo "0: No issues found"
echo "2: Warnings detected"
echo "4: Errors detected"
echo "8: Invalid CLI arguments"
echo "16: Fatal errors occurred"
echo ""

if [ $LINT_EXIT_CODE -eq 0 ]; then
  echo "✅ Action completed successfully - workflow can continue"
else
  echo "❌ Action completed with issues - workflow should handle exit code $LINT_EXIT_CODE"
fi

echo ""
echo "Test 1 completed with exit code: $LINT_EXIT_CODE"
echo ""

# Test with invalid template (should exit with non-zero)
echo "Test 2: Invalid template (expecting non-zero exit code)"
echo "-------------------------------------------------------"

TEMPLATE_PATH="test-invalid-template.yaml"
TEMPLATE_NAME=$(basename "$TEMPLATE_PATH")
FULL_TEMPLATE_PATH="$(pwd)/$TEMPLATE_PATH"

echo "Processing CloudFormation template: $TEMPLATE_NAME"

set +e
LINT_OUTPUT=$(cfn-lint --format parseable "$FULL_TEMPLATE_PATH" 2>&1)
LINT_EXIT_CODE=$?
set -e

echo ""
echo "=== CloudFormation Linting Summary ==="
echo "Template: $TEMPLATE_NAME"
echo "Exit Code: $LINT_EXIT_CODE"

case $LINT_EXIT_CODE in
  0)
    echo "Status: ✅ SUCCESS - No issues found"
    ;;
  2)
    echo "Status: ⚠️  WARNINGS - Template has warnings"
    ;;
  4)
    echo "Status: ❌ ERRORS - Template has errors"
    ;;
  6)
    echo "Status: ❌ ERRORS + WARNINGS - Template has both errors and warnings"
    ;;
  8)
    echo "Status: ❌ INVALID CLI - Invalid command line arguments"
    ;;
  16)
    echo "Status: ❌ FATAL - Fatal errors occurred"
    ;;
  *)
    echo "Status: ❌ UNKNOWN - Unexpected exit code: $LINT_EXIT_CODE"
    ;;
esac

if [ $LINT_EXIT_CODE -ne 0 ] && [ -n "$LINT_OUTPUT" ]; then
  echo ""
  echo "=== Detailed cfn-lint Output ==="
  echo "$LINT_OUTPUT"
fi

echo ""
echo "Test 2 completed with exit code: $LINT_EXIT_CODE"
echo ""
echo "Exit code handling tests completed!"