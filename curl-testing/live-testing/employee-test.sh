#!/bin/bash

################################################################################
# Employee API Testing Script
#
# This script provides functions to test all CRUD operations for the Employee
# entity in the TeamUP API.
#
# Usage: ./employee-test.sh <function> [arguments]
################################################################################

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ENDPOINT="/api/employees"

################################################################################
# CREATE - POST /api/employees
################################################################################

create_employee() {
    local fullname=""
    local job_title=""
    local age=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name|--fullname)
                fullname="$2"
                shift 2
                ;;
            -j|--job-title|--job)
                job_title="$2"
                shift 2
                ;;
            -a|--age)
                age="$2"
                shift 2
                ;;
            -h|--help)
                show_create_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_create_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "name/fullname" "$fullname"; then
        show_create_help
        return 1
    fi
    
    # Validate age if provided
    if [ -n "$age" ] && ! is_positive_integer "$age"; then
        print_error "Age must be a positive integer"
        return 1
    fi
    
    # Build JSON payload
    local json="{"
    json="$json\"fullname\":\"$fullname\""
    
    if [ -n "$job_title" ]; then
        json="$json,\"jobTitle\":\"$job_title\""
    fi
    
    if [ -n "$age" ]; then
        json="$json,\"age\":$age"
    fi
    
    json="$json}"
    
    # Validate JSON
    if ! is_valid_json "$json"; then
        print_error "Generated invalid JSON: $json"
        return 1
    fi
    
    print_header "Creating Employee"
    make_request "POST" "${BASE_URL}${ENDPOINT}" "$json" "Create_Employee"
}

show_create_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 create_employee -n <name> [-j <job_title>] [-a <age>]

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -n, --name, --fullname    Full name of the employee (max 50 chars)

${BOLD}OPTIONAL ARGUMENTS:${RESET}
  -j, --job-title, --job    Job title (max 30 chars)
  -a, --age                 Age (positive integer, 1-149)
  -h, --help                Show this help message

${BOLD}EXAMPLES:${RESET}
  # Create employee with name only
  $0 create_employee -n "John Doe"

  # Create employee with all fields
  $0 create_employee -n "Jane Smith" -j "Senior Developer" -a 30

  # Using alternative flags
  $0 create_employee --fullname "Bob Johnson" --job "Manager" --age 45

EOF
    display_common_help
}

################################################################################
# READ ALL - GET /api/employees
################################################################################

get_all_employees() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_get_all_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_get_all_help
                return 1
                ;;
        esac
    done
    
    print_header "Getting All Employees"
    make_request "GET" "${BASE_URL}${ENDPOINT}" "" "Get_All_Employees"
}

show_get_all_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 get_all_employees

${BOLD}DESCRIPTION:${RESET}
  Retrieves all employees from the database.

${BOLD}EXAMPLES:${RESET}
  $0 get_all_employees

EOF
    display_common_help
}

################################################################################
# READ ONE - GET /api/employees/{id}
################################################################################

get_employee() {
    local id=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--id)
                id="$2"
                shift 2
                ;;
            -h|--help)
                show_get_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_get_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "id" "$id"; then
        show_get_help
        return 1
    fi
    
    if ! is_positive_integer "$id"; then
        print_error "ID must be a positive integer"
        return 1
    fi
    
    print_header "Getting Employee by ID"
    make_request "GET" "${BASE_URL}${ENDPOINT}/${id}" "" "Get_Employee_${id}"
}

show_get_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 get_employee -i <id>

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -i, --id    ID of the employee to retrieve

${BOLD}EXAMPLES:${RESET}
  $0 get_employee -i 1
  $0 get_employee --id 42

EOF
    display_common_help
}

################################################################################
# UPDATE - PUT /api/employees/{id}
################################################################################

update_employee() {
    local id=""
    local fullname=""
    local job_title=""
    local age=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--id)
                id="$2"
                shift 2
                ;;
            -n|--name|--fullname)
                fullname="$2"
                shift 2
                ;;
            -j|--job-title|--job)
                job_title="$2"
                shift 2
                ;;
            -a|--age)
                age="$2"
                shift 2
                ;;
            -h|--help)
                show_update_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_update_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "id" "$id"; then
        show_update_help
        return 1
    fi
    
    if ! is_positive_integer "$id"; then
        print_error "ID must be a positive integer"
        return 1
    fi
    
    if ! require_arg "name/fullname" "$fullname"; then
        print_error "Name is required for update (the entire object must be provided)"
        show_update_help
        return 1
    fi
    
    # Validate age if provided
    if [ -n "$age" ] && ! is_positive_integer "$age"; then
        print_error "Age must be a positive integer"
        return 1
    fi
    
    # Build JSON payload
    local json="{"
    json="$json\"id\":$id,\"fullname\":\"$fullname\""
    
    if [ -n "$job_title" ]; then
        json="$json,\"jobTitle\":\"$job_title\""
    else
        json="$json,\"jobTitle\":null"
    fi
    
    if [ -n "$age" ]; then
        json="$json,\"age\":$age"
    else
        json="$json,\"age\":null"
    fi
    
    json="$json}"
    
    # Validate JSON
    if ! is_valid_json "$json"; then
        print_error "Generated invalid JSON: $json"
        return 1
    fi
    
    print_header "Updating Employee"
    make_request "PUT" "${BASE_URL}${ENDPOINT}/${id}" "$json" "Update_Employee_${id}"
}

show_update_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 update_employee -i <id> -n <name> [-j <job_title>] [-a <age>]

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -i, --id                  ID of the employee to update
  -n, --name, --fullname    Full name of the employee (max 50 chars)

${BOLD}OPTIONAL ARGUMENTS:${RESET}
  -j, --job-title, --job    Job title (max 30 chars, null if omitted)
  -a, --age                 Age (positive integer, null if omitted)
  -h, --help                Show this help message

${BOLD}NOTE:${RESET}
  PUT requires sending the complete object. All fields not specified will be
  set to null (except the required name field).

${BOLD}EXAMPLES:${RESET}
  # Update employee name only (other fields set to null)
  $0 update_employee -i 1 -n "John Smith"

  # Update all fields
  $0 update_employee -i 1 -n "Jane Doe" -j "Lead Developer" -a 32

  # Update name and job title (age will be null)
  $0 update_employee --id 5 --name "Bob Wilson" --job "CTO"

EOF
    display_common_help
}

################################################################################
# DELETE - DELETE /api/employees/{id}
################################################################################

delete_employee() {
    local id=""
    local confirm="no"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--id)
                id="$2"
                shift 2
                ;;
            -y|--yes|--confirm)
                confirm="yes"
                shift
                ;;
            -h|--help)
                show_delete_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_delete_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "id" "$id"; then
        show_delete_help
        return 1
    fi
    
    if ! is_positive_integer "$id"; then
        print_error "ID must be a positive integer"
        return 1
    fi
    
    # Ask for confirmation unless -y flag is provided
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Are you sure you want to delete employee with ID $id? (yes/no)${RESET}"
        read -r response
        if [ "$response" != "yes" ] && [ "$response" != "y" ]; then
            print_info "Delete cancelled"
            return 0
        fi
    fi
    
    print_header "Deleting Employee"
    make_request "DELETE" "${BASE_URL}${ENDPOINT}/${id}" "" "Delete_Employee_${id}"
}

show_delete_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 delete_employee -i <id> [-y]

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -i, --id    ID of the employee to delete

${BOLD}OPTIONAL ARGUMENTS:${RESET}
  -y, --yes, --confirm    Skip confirmation prompt
  -h, --help              Show this help message

${BOLD}EXAMPLES:${RESET}
  # Delete with confirmation prompt
  $0 delete_employee -i 1

  # Delete without confirmation
  $0 delete_employee -i 1 -y
  $0 delete_employee --id 42 --yes

EOF
    display_common_help
}

################################################################################
# Main Help
################################################################################

show_help() {
    cat << EOF

${BOLD}${CYAN}Employee API Testing Script${RESET}

${BOLD}USAGE:${RESET}
  $0 <function> [arguments]

${BOLD}AVAILABLE FUNCTIONS:${RESET}
  ${GREEN}create_employee${RESET}      Create a new employee
  ${GREEN}get_all_employees${RESET}    Get all employees
  ${GREEN}get_employee${RESET}          Get employee by ID
  ${GREEN}update_employee${RESET}      Update an existing employee
  ${GREEN}delete_employee${RESET}      Delete an employee by ID
  ${GREEN}help${RESET}                 Show this help message

${BOLD}QUICK START:${RESET}
  # Get help for a specific function
  $0 create_employee --help

  # Create a new employee
  $0 create_employee -n "John Doe" -j "Developer" -a 30

  # List all employees
  $0 get_all_employees

  # Get specific employee
  $0 get_employee -i 1

  # Update employee
  $0 update_employee -i 1 -n "John Smith" -j "Senior Developer" -a 31

  # Delete employee (with confirmation)
  $0 delete_employee -i 1

${BOLD}TESTING WORKFLOW:${RESET}
  1. Create: $0 create_employee -n "Test User" -j "Tester"
  2. List:   $0 get_all_employees
  3. Get:    $0 get_employee -i <id_from_create>
  4. Update: $0 update_employee -i <id> -n "Updated Name"
  5. Delete: $0 delete_employee -i <id> -y

EOF
    display_common_help
}

################################################################################
# Main Script Logic
################################################################################

# Check if function name is provided
if [ $# -eq 0 ]; then
    print_error "No function specified"
    show_help
    exit 1
fi

# Get function name
FUNCTION_NAME=$1
shift

# Check server before executing commands (except help)
if [ "$FUNCTION_NAME" != "help" ] && [ "$FUNCTION_NAME" != "--help" ] && [ "$FUNCTION_NAME" != "-h" ]; then
    if ! check_server; then
        exit 1
    fi
fi

# Execute function
case $FUNCTION_NAME in
    create|create_employee)
        create_employee "$@"
        ;;
    get-all|get_all|get_all_employees|list)
        get_all_employees "$@"
        ;;
    get|get_employee|get-employee)
        get_employee "$@"
        ;;
    update|update_employee|update-employee)
        update_employee "$@"
        ;;
    delete|delete_employee|delete-employee)
        delete_employee "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown function: $FUNCTION_NAME"
        show_help
        exit 1
        ;;
esac

exit $?
