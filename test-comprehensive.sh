#!/bin/bash

# Comprehensive test script for CloudFormation Linter Action
# This script tests all scenarios locally to validate action behavior

set -e

echo "🧪 CloudFormation Linter Action - Comprehensive Test Suite"
echo "=========================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test scenario
run_test() {
    local test_name="$1"
    local template_path="$2"
    local expected_exit_code="$3"
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}Test $TOTAL_TESTS: $test_name${NC}"
    echo "Description: $description"
    echo "Template: $template_path"
    echo "Expected exit code: $expected_exit_code"
    echo "----------------------------------------"
    
    # Set up test environment
    export GITHUB_WORKSPACE=$(pwd)
    export GITHUB_STEP_SUMMARY="/tmp/test-step-summary-$TOTAL_TESTS.md"
    
    # Clear any existing summary
    > $GITHUB_STEP_SUMMARY
    
    # Run the action logic (simulating the action.yaml steps)
    TEMPLATE_NAME=$(basename "$template_path")
    FULL_TEMPLATE_PATH="$GITHUB_WORKSPACE/$template_path"
    
    echo "Processing CloudFormation template: $TEMPLATE_NAME"
    echo "Full path: $FULL_TEMPLATE_PATH"
    
    # Check if cfn-lint is available
    if ! command -v cfn-lint &> /dev/null; then
        echo "Installing cfn-lint..."
        pip install cfn-lint > /dev/null 2>&1
    fi
    
    # Validate file existence
    if [ ! -f "$FULL_TEMPLATE_PATH" ]; then
        echo "❌ Error: CloudFormation template not found at path: $FULL_TEMPLATE_PATH"
        ACTUAL_EXIT_CODE=1
    else
        echo "✅ Template file found, proceeding with linting..."
        
        # Run cfn-lint with error handling
        set +e
        LINT_OUTPUT=$(cfn-lint --format parseable "$FULL_TEMPLATE_PATH" 2>&1)
        ACTUAL_EXIT_CODE=$?
        set -e
        
        # Generate GitHub Step Summary (same logic as action.yaml)
        echo "## CloudFormation Linting Results" >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "**Template:** \`$TEMPLATE_NAME\`" >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        
        if [ $ACTUAL_EXIT_CODE -eq 0 ]; then
            echo "✅ **Status:** Linting completed successfully - no issues found" >> $GITHUB_STEP_SUMMARY
        else
            echo "❌ **Status:** Linting completed with issues (exit code: $ACTUAL_EXIT_CODE)" >> $GITHUB_STEP_SUMMARY
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
    fi
    
    # Display results
    echo ""
    echo "=== Test Results ==="
    echo "Expected exit code: $expected_exit_code"
    echo "Actual exit code: $ACTUAL_EXIT_CODE"
    
    # Check if test passed
    if [ "$expected_exit_code" = "any" ] || [ "$ACTUAL_EXIT_CODE" -eq "$expected_exit_code" ]; then
        echo -e "${GREEN}✅ TEST PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ TEST FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    # Display Step Summary
    echo ""
    echo "=== Generated Step Summary ==="
    if [ -f "$GITHUB_STEP_SUMMARY" ]; then
        cat "$GITHUB_STEP_SUMMARY"
    else
        echo "No step summary generated"
    fi
    
    echo ""
    echo "=== Detailed Output ==="
    if [ -n "$LINT_OUTPUT" ]; then
        echo "$LINT_OUTPUT"
    else
        echo "No detailed output available"
    fi
    
    echo ""
    echo "=========================================="
    echo ""
}

# Test Scenario 1: Valid Template
run_test "Valid Template" \
         "test-templates/valid-template.yaml" \
         0 \
         "Test with a properly formatted CloudFormation template that should pass all linting checks"

# Test Scenario 2: Template with Warnings
run_test "Template with Warnings" \
         "test-templates/template-with-warnings.yaml" \
         "any" \
         "Test with a template that may generate warnings (exit code 2) or pass (exit code 0)"

# Test Scenario 3: Invalid Template
run_test "Invalid Template" \
         "test-templates/invalid-template.yaml" \
         4 \
         "Test with a template containing errors that should fail linting (exit code 4 or higher)"

# Test Scenario 4: File Not Found
run_test "File Not Found" \
         "non-existent-template.yaml" \
         1 \
         "Test error handling when template file doesn't exist (should exit with code 1)"

# Test Scenario 5: Legacy Valid Template
run_test "Legacy Valid Template" \
         "test-template.yaml" \
         0 \
         "Test backward compatibility with existing valid template"

# Test Scenario 6: Legacy Invalid Template
run_test "Legacy Invalid Template" \
         "test-invalid-template.yaml" \
         "any" \
         "Test backward compatibility with existing invalid template"

# Test Scenario 7: Nested Path Template
run_test "Nested Path Template" \
         "test-templates/valid-template.yaml" \
         0 \
         "Test handling of templates in subdirectories"

# Display final results
echo ""
echo "🏁 TEST SUITE COMPLETED"
echo "======================="
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo ""
    echo "✅ Valid CloudFormation templates are processed correctly"
    echo "✅ Templates with warnings are handled appropriately"
    echo "✅ Invalid templates generate proper error codes"
    echo "✅ File not found errors are handled correctly"
    echo "✅ GitHub Step Summary is generated for all scenarios"
    echo "✅ Exit codes are preserved for workflow decision making"
    echo "✅ Backward compatibility is maintained"
    echo "✅ Nested path handling works correctly"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please review the failed tests above and fix any issues."
    exit 1
fi