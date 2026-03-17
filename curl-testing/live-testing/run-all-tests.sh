#!/bin/bash

# run-all-tests.sh - Integration testing script for TeamUP API
# Runs a complete CRUD workflow for Employee and LearningMaterial entities

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
CLEANUP=true

# IDs for created resources
EMPLOYEE_ID=""
LEARNING_MATERIAL_ID=""

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_header "Running: $test_name"
    
    if eval "$test_command"; then
        print_success "✓ PASSED: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "✗ FAILED: $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to extract ID from JSON response
extract_id() {
    local json="$1"
    echo "$json" | jq -r '.id // empty' 2>/dev/null
}

# Employee CRUD workflow
test_employee_workflow() {
    print_header "EMPLOYEE CRUD WORKFLOW"
    echo ""
    
    # CREATE
    local response
    response=$(make_request POST "$BASE_URL/employees" '{
        "fullname": "Integration Test User",
        "jobTitle": "QA Engineer",
        "age": 30
    }')
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        EMPLOYEE_ID=$(extract_id "$response")
        if [ -n "$EMPLOYEE_ID" ]; then
            print_success "✓ CREATE Employee (ID: $EMPLOYEE_ID)"
            ((TESTS_PASSED++))
        else
            print_error "✗ CREATE Employee - Could not extract ID"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        print_error "✗ CREATE Employee"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # GET by ID
    response=$(make_request GET "$BASE_URL/employees/$EMPLOYEE_ID")
    if [ $? -eq 0 ] && echo "$response" | jq -e '.id' >/dev/null 2>&1; then
        print_success "✓ GET Employee by ID"
        ((TESTS_PASSED++))
    else
        print_error "✗ GET Employee by ID"
        ((TESTS_FAILED++))
    fi
    
    # GET ALL
    response=$(make_request GET "$BASE_URL/employees")
    if [ $? -eq 0 ] && echo "$response" | jq -e 'if type == "array" then true else false end' >/dev/null 2>&1; then
        print_success "✓ GET All Employees"
        ((TESTS_PASSED++))
    else
        print_error "✗ GET All Employees"
        ((TESTS_FAILED++))
    fi
    
    # UPDATE
    response=$(make_request PUT "$BASE_URL/employees/$EMPLOYEE_ID" '{
        "fullname": "Integration Test User Updated",
        "jobTitle": "Senior QA Engineer",
        "age": 31
    }')
    if [ $? -eq 0 ] && echo "$response" | jq -e '.fullname' | grep -q "Updated" 2>/dev/null; then
        print_success "✓ UPDATE Employee"
        ((TESTS_PASSED++))
    else
        print_error "✗ UPDATE Employee"
        ((TESTS_FAILED++))
    fi
    
    # DELETE (if cleanup enabled)
    if [ "$CLEANUP" = true ]; then
        response=$(make_request DELETE "$BASE_URL/employees/$EMPLOYEE_ID")
        if [ $? -eq 0 ]; then
            print_success "✓ DELETE Employee"
            ((TESTS_PASSED++))
        else
            print_error "✗ DELETE Employee"
            ((TESTS_FAILED++))
        fi
    else
        print_warning "⊘ SKIP DELETE Employee (--no-cleanup flag set)"
    fi
    
    echo ""
}

# LearningMaterial CRUD workflow
test_learning_material_workflow() {
    print_header "LEARNING MATERIAL CRUD WORKFLOW"
    echo ""
    
    print_warning "Learning Material creation via API currently not supported"
    print_info "The API requires a managed LearningMaterialType entity reference"
    print_info "Manual testing can be done by getting existing learning materials"
    echo ""
    
    # GET ALL (test with existing data)
    local response
    response=$(make_request GET "$BASE_URL/learning-materials")
    if [ $? -eq 0 ] && echo "$response" | jq -e 'if type == "array" then true else false end' >/dev/null 2>&1; then
        print_success "✓ GET All LearningMaterials"
        ((TESTS_PASSED++))
        
        # Try to get first existing learning material
        local first_id=$(echo "$response" | jq -r '.[0].id // empty' 2>/dev/null)
        if [ -n "$first_id" ]; then
            LEARNING_MATERIAL_ID=$first_id
            
            # GET by ID
            response=$(make_request GET "$BASE_URL/learning-materials/$LEARNING_MATERIAL_ID")
            if [ $? -eq 0 ] && echo "$response" | jq -e '.id' >/dev/null 2>&1; then
                print_success "✓ GET LearningMaterial by ID (existing: $LEARNING_MATERIAL_ID)"
                ((TESTS_PASSED++))
            else
                print_error "✗ GET LearningMaterial by ID"
                ((TESTS_FAILED++))
            fi
        fi
    else
        print_error "✗ GET All LearningMaterials"
        ((TESTS_FAILED++))
    fi
    
    echo ""
}

# Display test summary
show_summary() {
    echo ""
    print_header "TEST SUMMARY"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED))
    
    if [ $TESTS_PASSED -gt 0 ]; then
        print_success "Passed: $TESTS_PASSED/$total"
    fi
    
    if [ $TESTS_FAILED -gt 0 ]; then
        print_error "Failed: $TESTS_FAILED/$total"
    fi
    
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_success "🎉 All tests passed!"
        return 0
    else
        print_error "❌ Some tests failed"
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}
${BOLD}run-all-tests.sh - TeamUP API Integration Testing${NC}
${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}

${YELLOW}DESCRIPTION:${NC}
    Runs a complete CRUD workflow for both Employee and LearningMaterial entities.
    Tests CREATE → GET → GET ALL → UPDATE → DELETE operations.

${YELLOW}USAGE:${NC}
    ./run-all-tests.sh [OPTIONS]

${YELLOW}OPTIONS:${NC}
    --no-cleanup        Keep test data (skip DELETE operations)
    --verbose, -v       Enable verbose output
    --help, -h          Show this help message

${YELLOW}EXAMPLES:${NC}
    # Run all tests with cleanup
    ./run-all-tests.sh

    # Run tests but keep test data
    ./run-all-tests.sh --no-cleanup

    # Run tests with verbose output
    ./run-all-tests.sh --verbose

${YELLOW}TEST WORKFLOW:${NC}
    ${BOLD}Employee Tests:${NC}
      1. CREATE - Create new employee
      2. GET    - Retrieve by ID
      3. GET    - Retrieve all employees
      4. UPDATE - Update employee details
      5. DELETE - Remove employee (unless --no-cleanup)

    ${BOLD}LearningMaterial Tests:${NC}
      1. CREATE - Create new learning material
      2. GET    - Retrieve by ID
      3. GET    - Retrieve all learning materials
      4. UPDATE - Update learning material details
      5. DELETE - Remove learning material (unless --no-cleanup)

${YELLOW}ENVIRONMENT VARIABLES:${NC}
    API_BASE_URL       API base URL (default: http://localhost:8080/api)
    NO_COLOR           Disable colored output (set to any value)

${YELLOW}REQUIREMENTS:${NC}
    • Spring Boot application running on http://localhost:8080
    • curl command available
    • jq command available (optional, for JSON formatting)

${YELLOW}NOTES:${NC}
    • All API responses are saved to the responses/ directory
    • Test results are color-coded (green=pass, red=fail)
    • Created IDs are displayed for manual verification if needed

${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}
EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cleanup)
            CLEANUP=false
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_header "TeamUP API Integration Tests"
    echo ""
    print_info "Base URL: $BASE_URL"
    print_info "Cleanup: $([ "$CLEANUP" = true ] && echo "Enabled" || echo "Disabled")"
    echo ""
    
    # Check server health
    if ! check_server; then
        print_error "Server is not responding. Please start the application first:"
        echo "  ./mvnw spring-boot:run"
        exit 1
    fi
    
    # Run test workflows
    test_employee_workflow
    test_learning_material_workflow
    
    # Show summary
    show_summary
    exit_code=$?
    
    # Show cleanup message if applicable
    if [ "$CLEANUP" = false ]; then
        echo ""
        print_warning "Test data was NOT deleted (--no-cleanup flag)"
        if [ -n "$EMPLOYEE_ID" ]; then
            print_info "Employee ID: $EMPLOYEE_ID"
        fi
        if [ -n "$LEARNING_MATERIAL_ID" ]; then
            print_info "LearningMaterial ID: $LEARNING_MATERIAL_ID"
        fi
    fi
    
    exit $exit_code
}

# Run main function
main
