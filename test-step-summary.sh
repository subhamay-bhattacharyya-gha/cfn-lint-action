#!/bin/bash

# Test script to verify GitHub Step Summary generation
# This simulates the action execution for testing purposes

# Set up test environment
export GITHUB_WORKSPACE=$(pwd)
export GITHUB_STEP_SUMMARY="/tmp/test-step-summary.md"

# Clear any existing summary
> $GITHUB_STEP_SUMMARY

# Test with template (can be changed via argument)
TEMPLATE_PATH="${1:-test-template.yaml}"
TEMPLATE_NAME=$(basename "$TEMPLATE_PATH")
FULL_TEMPLATE_PATH="$GITHUB_WORKSPACE/$TEMPLATE_PATH"

echo "Testing GitHub Step Summary generation..."
echo "Template: $TEMPLATE_NAME"
echo "Full path: $FULL_TEMPLATE_PATH"

# Check if cfn-lint is available
if ! command -v cfn-lint &> /dev/null; then
    echo "cfn-lint not found, installing..."
    pip install cfn-lint
fi

# Validate file existence
if [ ! -f "$FULL_TEMPLATE_PATH" ]; then
  echo "❌ Error: CloudFormation template not found at path: $FULL_TEMPLATE_PATH"
  exit 1
fi

echo "✅ Template file found, proceeding with linting..."

# Run cfn-lint with error handling
set +e
LINT_OUTPUT=$(cfn-lint --format parseable "$FULL_TEMPLATE_PATH" 2>&1)
LINT_EXIT_CODE=$?
set -e

# Generate GitHub Step Summary (same logic as in action.yaml)
echo "## CloudFormation Linting Results" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY
echo "**Template:** \`$TEMPLATE_NAME\`" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

if [ $LINT_EXIT_CODE -eq 0 ]; then
  echo "✅ **Status:** Linting completed successfully - no issues found" >> $GITHUB_STEP_SUMMARY
else
  echo "❌ **Status:** Linting completed with issues (exit code: $LINT_EXIT_CODE)" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "**Exit Code Meanings:**" >> $GITHUB_STEP_SUMMARY
  echo "- 0: No issues found" >> $GITHUB_STEP_SUMMARY
  echo "- 2: Warnings detected" >> $GITHUB_STEP_SUMMARY
  echo "- 4: Errors detected" >> $GITHUB_STEP_SUMMARY
  echo "- 8: Invalid CLI arguments" >> $GITHUB_STEP_SUMMARY
  echo "- 16: Fatal errors occurred" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  
  if [ -n "$LINT_OUTPUT" ]; then
    echo "**Detailed Output:**" >> $GITHUB_STEP_SUMMARY
    echo '```' >> $GITHUB_STEP_SUMMARY
    echo "$LINT_OUTPUT" >> $GITHUB_STEP_SUMMARY
    echo '```' >> $GITHUB_STEP_SUMMARY
  fi
fi

# Display the generated summary
echo ""
echo "Generated GitHub Step Summary:"
echo "================================"
cat $GITHUB_STEP_SUMMARY
echo "================================"

# Display final status
if [ $LINT_EXIT_CODE -eq 0 ]; then
  echo "✅ CloudFormation linting completed successfully"
else
  echo "❌ CloudFormation linting completed with exit code: $LINT_EXIT_CODE"
  if [ -n "$LINT_OUTPUT" ]; then
    echo "Detailed output:"
    echo "$LINT_OUTPUT"
  fi
fi

exit $LINT_EXIT_CODE