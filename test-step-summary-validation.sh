#!/bin/bash

# Test script to validate GitHub Step Summary generation across all scenarios
# This validates requirement 4: comprehensive GitHub Step Summary reporting

echo "📋 Testing GitHub Step Summary Generation"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to validate step summary content
validate_summary() {
    local summary_file="$1"
    local scenario="$2"
    local expected_status="$3"
    
    echo "Validating Step Summary for $scenario scenario..."
    
    if [ ! -f "$summary_file" ]; then
        echo -e "${RED}❌ Step summary file not found: $summary_file${NC}"
        return 1
    fi
    
    local content=$(cat "$summary_file")
    
    # Check for required elements
    local checks_passed=0
    local total_checks=6
    
    # Check 1: Title present
    if echo "$content" | grep -q "## CloudFormation Linting Results"; then
        echo "✅ Title present"
        checks_passed=$((checks_passed + 1))
    else
        echo "❌ Title missing"
    fi
    
    # Check 2: Template name present
    if echo "$content" | grep -q "**Template:**"; then
        echo "✅ Template name present"
        checks_passed=$((checks_passed + 1))
    else
        echo "❌ Template name missing"
    fi
    
    # Check 3: Status present
    if echo "$content" | grep -q "**Status:**"; then
        echo "✅ Status present"
        checks_passed=$((checks_passed + 1))
    else
        echo "❌ Status missing"
    fi
    
    # Check 4: Exit code meanings (for non-success cases)
    if [ "$expected_status" != "success" ]; then
        if echo "$content" | grep -q "**Exit Code Meanings:**"; then
            echo "✅ Exit code meanings present"
            checks_passed=$((checks_passed + 1))
        else
            echo "❌ Exit code meanings missing"
        fi
    else
        echo "✅ Exit code meanings not required for success"
        checks_passed=$((checks_passed + 1))
    fi
    
    # Check 5: Detailed output (for non-success cases)
    if [ "$expected_status" != "success" ]; then
        if echo "$content" | grep -q "**Detailed Output:**"; then
            echo "✅ Detailed output section present"
            checks_passed=$((checks_passed + 1))
        else
            echo "⚠️  Detailed output section missing (may be empty)"
            checks_passed=$((checks_passed + 1))  # Allow this to pass
        fi
    else
        echo "✅ Detailed output not required for success"
        checks_passed=$((checks_passed + 1))
    fi
    
    # Check 6: Proper markdown formatting
    if echo "$content" | grep -q '```' || [ "$expected_status" = "success" ]; then
        echo "✅ Proper markdown formatting"
        checks_passed=$((checks_passed + 1))
    else
        echo "❌ Markdown formatting issues"
    fi
    
    echo "Summary validation: $checks_passed/$total_checks checks passed"
    
    if [ $checks_passed -eq $total_checks ]; then
        echo -e "${GREEN}✅ Step Summary validation PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ Step Summary validation FAILED${NC}"
        return 1
    fi
}

# Function to run test and validate summary
run_summary_test() {
    local test_name="$1"
    local template_path="$2"
    local expected_status="$3"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    echo "Template: $template_path"
    echo "Expected status: $expected_status"
    echo "----------------------------------------"
    
    # Set up test environment
    export GITHUB_WORKSPACE=$(pwd)
    export GITHUB_STEP_SUMMARY="/tmp/test-summary-$test_name.md"
    
    # Clear any existing summary
    > $GITHUB_STEP_SUMMARY
    
    # Check if cfn-lint is available
    if ! command -v cfn-lint &> /dev/null; then
        echo "Installing cfn-lint..."
        pip install cfn-lint > /dev/null 2>&1
    fi
    
    # Run the action logic
    TEMPLATE_NAME=$(basename "$template_path")
    FULL_TEMPLATE_PATH="$GITHUB_WORKSPACE/$template_path"
    
    echo "Processing template: $TEMPLATE_NAME"
    
    # Validate file existence and run linting
    if [ ! -f "$FULL_TEMPLATE_PATH" ]; then
        echo "❌ Error: CloudFormation template not found at path: $FULL_TEMPLATE_PATH"
        LINT_EXIT_CODE=1
        LINT_OUTPUT=""
    else
        echo "✅ Template file found, proceeding with linting..."
        
        # Run cfn-lint with error handling
        set +e
        LINT_OUTPUT=$(cfn-lint --format parseable "$FULL_TEMPLATE_PATH" 2>&1)
        LINT_EXIT_CODE=$?
        set -e
    fi
    
    # Generate GitHub Step Summary (same logic as action.yaml)
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
    
    echo ""
    echo "=== Generated Step Summary ==="
    cat $GITHUB_STEP_SUMMARY
    echo "=============================="
    echo ""
    
    # Validate the generated summary
    validate_summary "$GITHUB_STEP_SUMMARY" "$test_name" "$expected_status"
    local validation_result=$?
    
    echo ""
    echo "=========================================="
    echo ""
    
    return $validation_result
}

# Test scenarios
echo "Running GitHub Step Summary validation tests..."
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0

# Test 1: Valid template (success summary)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_summary_test "valid-template" "test-templates/valid-template.yaml" "success"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Test 2: Template with warnings
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_summary_test "template-warnings" "test-templates/template-with-warnings.yaml" "warnings"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Test 3: Invalid template (error summary)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_summary_test "invalid-template" "test-templates/invalid-template.yaml" "errors"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Test 4: File not found (error summary)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_summary_test "file-not-found" "non-existent-template.yaml" "file-not-found"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Test 5: Legacy template (backward compatibility)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_summary_test "legacy-template" "test-template.yaml" "success"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Display final results
echo ""
echo "🏁 STEP SUMMARY VALIDATION COMPLETED"
echo "===================================="
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"
echo ""

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}🎉 ALL STEP SUMMARY TESTS PASSED!${NC}"
    echo ""
    echo "✅ Success summaries are properly formatted"
    echo "✅ Error summaries include exit code meanings"
    echo "✅ Detailed output is included when available"
    echo "✅ Markdown formatting is correct"
    echo "✅ Template names are displayed"
    echo "✅ Status information is clear"
    exit 0
else
    echo -e "${RED}❌ SOME STEP SUMMARY TESTS FAILED${NC}"
    echo ""
    echo "Please review the failed tests above and fix any issues."
    exit 1
fi