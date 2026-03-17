#!/bin/bash

################################################################################
# Common Utilities for TeamUP API Testing
# 
# This file provides shared functions and utilities for API testing scripts.
# Source this file in your test scripts with: source "$(dirname "$0")/common.sh"
################################################################################

# Configuration
export BASE_URL="${API_BASE_URL:-http://localhost:8080/api}"
export RESPONSE_DIR="${RESPONSE_DIR:-$(dirname "$0")/responses}"
export VERBOSE="${VERBOSE:-0}"
export SAVE_RESPONSES="${SAVE_RESPONSES:-1}"

# Color codes (can be disabled with NO_COLOR=1)
if [ -z "${NO_COLOR}" ]; then
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[0;34m'
    export CYAN='\033[0;36m'
    export MAGENTA='\033[0;35m'
    export BOLD='\033[1m'
    export RESET='\033[0m'
else
    export RED=''
    export GREEN=''
    export YELLOW=''
    export BLUE=''
    export CYAN=''
    export MAGENTA=''
    export BOLD=''
    export RESET=''
fi

################################################################################
# Output Functions
################################################################################

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${RESET}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${RESET}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${RESET}"
}

print_header() {
    echo -e "\n${BOLD}${CYAN}$1${RESET}"
    echo -e "${CYAN}$(printf '=%.0s' {1..80})${RESET}"
}

print_verbose() {
    if [ "$VERBOSE" = "1" ]; then
        echo -e "${MAGENTA}[VERBOSE] $1${RESET}"
    fi
}

################################################################################
# JSON Formatting
################################################################################

# Check if jq is available
has_jq() {
    command -v jq &> /dev/null
}

# Format JSON output with jq if available, otherwise just cat
format_json() {
    if has_jq; then
        jq '.' 2>/dev/null || cat
    else
        cat
    fi
}

# Pretty print JSON with color if jq is available
pretty_json() {
    if has_jq; then
        jq -C '.' 2>/dev/null || cat
    else
        cat
    fi
}

# Validate JSON format
is_valid_json() {
    local json="$1"
    if has_jq; then
        echo "$json" | jq empty 2>/dev/null
        return $?
    else
        # Basic validation without jq
        [[ "$json" =~ ^[[:space:]]*(\{.*\}|\[.*\])[[:space:]]*$ ]]
        return $?
    fi
}

################################################################################
# HTTP Request Functions
################################################################################

# Make HTTP request and save response
# Usage: make_request METHOD URL [DATA] [DESCRIPTION]
make_request() {
    local method="$1"
    local url="$2"
    local data="$3"
    local description="${4:-API request}"
    
    local response_file=""
    local http_code=""
    local response_body=""
    local temp_response=$(mktemp)
    
    print_verbose "Making $method request to: $url"
    
    # Build curl command
    local curl_cmd="curl -s -w '\n%{http_code}' -X $method"
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
        print_verbose "Request body: $data"
    fi
    
    curl_cmd="$curl_cmd '$url'"
    
    # Execute request and capture output
    local full_response=$(eval $curl_cmd)
    
    # Split response body and HTTP code
    response_body=$(echo "$full_response" | sed '$d')
    http_code=$(echo "$full_response" | tail -n1)
    
    print_verbose "HTTP Status: $http_code"
    
    # Save response if enabled
    if [ "$SAVE_RESPONSES" = "1" ]; then
        save_response "$response_body" "$method" "$description"
    fi
    
    # Check HTTP status and display result (to stderr to not interfere with response capture)
    case "$http_code" in
        200|201)
            print_success "$description - Status: $http_code" >&2
            ;;
        204)
            print_success "$description - Status: $http_code (No Content)" >&2
            ;;
        400)
            print_error "$description - Status: $http_code (Bad Request)" >&2
            ;;
        404)
            print_error "$description - Status: $http_code (Not Found)" >&2
            ;;
        500)
            print_error "$description - Status: $http_code (Internal Server Error)" >&2
            ;;
        *)
            print_warning "$description - Status: $http_code" >&2
            ;;
    esac
    
    # Display response body
    if [ -n "$response_body" ] && [ "$response_body" != "null" ]; then
        echo -e "\n${BOLD}Response:${RESET}" >&2
        echo "$response_body" | pretty_json >&2
    fi
    
    echo "" >&2
    
    # Echo response body to stdout for capture
    echo "$response_body"
    
    # Return success/failure based on HTTP code
    [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]
    return $?
}

# Save response to file
save_response() {
    local response="$1"
    local method="$2"
    local description="$3"
    
    # Create responses directory if it doesn't exist
    mkdir -p "$RESPONSE_DIR"
    
    # Generate filename with timestamp
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local safe_desc=$(echo "$description" | tr ' ' '_' | tr -cd '[:alnum:]_-')
    local filename="${RESPONSE_DIR}/${method}_${safe_desc}_${timestamp}.json"
    
    # Save response
    echo "$response" | format_json > "$filename" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_verbose "Response saved to: $filename"
    fi
}

################################################################################
# Validation Functions
################################################################################

# Check if a value is a valid integer
is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

# Check if a value is a valid positive integer
is_positive_integer() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]
}

# Validate required argument
require_arg() {
    local arg_name="$1"
    local arg_value="$2"
    
    if [ -z "$arg_value" ]; then
        print_error "Required argument missing: $arg_name"
        return 1
    fi
    return 0
}

################################################################################
# Server Health Check
################################################################################

# Check if the API server is running
check_server() {
    local health_url="${BASE_URL}/employees"
    
    print_info "Checking server health at: $BASE_URL"
    
    if curl -s -f -m 5 "${health_url}" > /dev/null 2>&1; then
        print_success "Server is running"
        return 0
    else
        print_error "Cannot connect to server at $BASE_URL"
        print_info "Make sure the Spring Boot application is running"
        print_info "You can start it with: ./mvnw spring-boot:run"
        return 1
    fi
}

################################################################################
# Array Conversion Functions
################################################################################

# Convert comma-separated values to JSON array
# Usage: csv_to_json_array "1,2,3" -> [1,2,3]
csv_to_json_array() {
    local csv="$1"
    
    if [ -z "$csv" ]; then
        echo "[]"
        return
    fi
    
    # Remove spaces and convert to array
    csv=$(echo "$csv" | tr -d ' ')
    
    if has_jq; then
        echo "$csv" | jq -R 'split(",") | map(tonumber)'
    else
        # Manual conversion without jq
        echo -n "["
        echo -n "$csv" | sed 's/,/,/g'
        echo "]"
    fi
}

################################################################################
# Help Functions
################################################################################

# Display common usage information
display_common_help() {
    cat << EOF

${BOLD}ENVIRONMENT VARIABLES:${RESET}
  API_BASE_URL      Override the base URL (default: http://localhost:8080)
  RESPONSE_DIR      Directory to save responses (default: ./responses)
  SAVE_RESPONSES    Save responses to files (default: 1)
  VERBOSE           Show verbose output (default: 0)
  NO_COLOR          Disable colored output

${BOLD}EXAMPLES:${RESET}
  # Change base URL
  API_BASE_URL=http://localhost:9090 $0 get_all

  # Enable verbose mode
  VERBOSE=1 $0 create -n "Test"

  # Disable response saving
  SAVE_RESPONSES=0 $0 get_all

  # Disable colors
  NO_COLOR=1 $0 get_all

EOF
}

################################################################################
# Initialize
################################################################################

# Create response directory if saving is enabled
if [ "$SAVE_RESPONSES" = "1" ]; then
    mkdir -p "$RESPONSE_DIR"
fi

# Warn if jq is not installed
if ! has_jq && [ "$VERBOSE" = "1" ]; then
    print_warning "jq is not installed. JSON output will not be pretty-printed."
    print_info "Install jq for better JSON formatting: sudo apt install jq"
fi
