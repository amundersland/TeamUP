#!/bin/bash

################################################################################
# Learning Material API Testing Script
#
# This script provides functions to test all CRUD operations for the Learning
# Material entity in the TeamUP API.
#
# Usage: ./learning-material-test.sh <function> [arguments]
################################################################################

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ENDPOINT="/api/learning-materials"

################################################################################
# CREATE - POST /api/learning-materials
################################################################################

create_learning_material() {
    local name=""
    local description=""
    local link=""
    local price=""
    local type_id=""
    local tag_ids=""
    local wiki_note_ids=""
    local notes="[]"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -d|--description|--desc)
                description="$2"
                shift 2
                ;;
            -l|--link|--url)
                link="$2"
                shift 2
                ;;
            -p|--price)
                price="$2"
                shift 2
                ;;
            -t|--type-id|--type)
                type_id="$2"
                shift 2
                ;;
            --tag-ids|--tags)
                tag_ids="$2"
                shift 2
                ;;
            --wiki-note-ids|--wiki-notes)
                wiki_note_ids="$2"
                shift 2
                ;;
            --notes)
                notes="$2"
                shift 2
                ;;
            -h|--help)
                show_create_lm_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_create_lm_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "name" "$name"; then
        show_create_lm_help
        return 1
    fi
    
    if ! require_arg "type-id" "$type_id"; then
        print_error "Type ID is required. Available types:"
        print_info "  2 = Book"
        print_info "  3 = Online Course"
        print_info "  4 = YouTube"
        print_info "  5 = Live Course"
        show_create_lm_help
        return 1
    fi
    
    # Validate numeric fields
    if ! is_positive_integer "$type_id"; then
        print_error "Type ID must be a positive integer"
        return 1
    fi
    
    if [ -n "$price" ] && ! is_integer "$price"; then
        print_error "Price must be an integer (in smallest currency unit, e.g., cents)"
        return 1
    fi
    
    # Convert comma-separated IDs to JSON arrays
    local tag_ids_json="[]"
    if [ -n "$tag_ids" ]; then
        tag_ids_json=$(csv_to_json_array "$tag_ids")
    fi
    
    local wiki_note_ids_json="[]"
    if [ -n "$wiki_note_ids" ]; then
        wiki_note_ids_json=$(csv_to_json_array "$wiki_note_ids")
    fi
    
    # Validate notes JSON
    if ! is_valid_json "$notes"; then
        print_error "Notes must be valid JSON (e.g., '[]' or '[{\"content\":\"note\"}]')"
        return 1
    fi
    
    # Build JSON payload
    local json="{"
    json="$json\"name\":\"$name\""
    
    if [ -n "$description" ]; then
        json="$json,\"description\":\"$description\""
    fi
    
    if [ -n "$link" ]; then
        json="$json,\"link\":\"$link\""
    fi
    
    if [ -n "$price" ]; then
        json="$json,\"price\":$price"
    fi
    
    json="$json,\"type\":{\"id\":$type_id}"
    json="$json,\"tagIds\":$tag_ids_json"
    json="$json,\"wikiNoteIds\":$wiki_note_ids_json"
    json="$json,\"notes\":\"$(echo "$notes" | sed 's/"/\\"/g')\""
    
    json="$json}"
    
    # Validate JSON
    if ! is_valid_json "$json"; then
        print_error "Generated invalid JSON: $json"
        return 1
    fi
    
    print_header "Creating Learning Material"
    make_request "POST" "${BASE_URL}${ENDPOINT}" "$json" "Create_Learning_Material"
}

show_create_lm_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 create_learning_material -n <name> -t <type_id> [options]

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -n, --name              Name of the learning material (max 100 chars)
  -t, --type-id, --type   Type ID (2=Book, 3=Online Course, 4=YouTube, 5=Live Course)

${BOLD}OPTIONAL ARGUMENTS:${RESET}
  -d, --description       Description of the material
  -l, --link, --url       URL/link to the material (max 100 chars)
  -p, --price             Price in smallest currency unit (e.g., cents)
  --tag-ids, --tags       Comma-separated tag IDs (e.g., "1,2,3")
  --wiki-note-ids         Comma-separated wiki note IDs (e.g., "1,2")
  --notes                 JSON array of notes (default: "[]")
  -h, --help              Show this help message

${BOLD}AVAILABLE TYPES:${RESET}
  2    Book
  3    Online Course
  4    YouTube
  5    Live Course

${BOLD}EXAMPLES:${RESET}
  # Minimal - just name and type
  $0 create_learning_material -n "Kotlin in Action" -t 2

  # Book with full details
  $0 create_learning_material \\
    -n "Spring Boot in Action" \\
    -t 2 \\
    -d "Comprehensive guide to Spring Boot development" \\
    -l "https://example.com/spring-boot" \\
    -p 4995

  # Online course with tags
  $0 create_learning_material \\
    -n "Advanced Kotlin Course" \\
    -t 3 \\
    -l "https://udemy.com/kotlin" \\
    -p 9999 \\
    --tags "1,2,3"

  # YouTube video with notes
  $0 create_learning_material \\
    -n "Spring Boot Tutorial" \\
    -t 4 \\
    -l "https://youtube.com/watch?v=xxx" \\
    --notes '[]'

EOF
    display_common_help
}

################################################################################
# READ ALL - GET /api/learning-materials
################################################################################

get_all_learning_materials() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_get_all_lm_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_get_all_lm_help
                return 1
                ;;
        esac
    done
    
    print_header "Getting All Learning Materials"
    make_request "GET" "${BASE_URL}${ENDPOINT}" "" "Get_All_Learning_Materials"
}

show_get_all_lm_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 get_all_learning_materials

${BOLD}DESCRIPTION:${RESET}
  Retrieves all learning materials from the database.

${BOLD}EXAMPLES:${RESET}
  $0 get_all_learning_materials

EOF
    display_common_help
}

################################################################################
# READ ONE - GET /api/learning-materials/{id}
################################################################################

get_learning_material() {
    local id=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--id)
                id="$2"
                shift 2
                ;;
            -h|--help)
                show_get_lm_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_get_lm_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "id" "$id"; then
        show_get_lm_help
        return 1
    fi
    
    if ! is_positive_integer "$id"; then
        print_error "ID must be a positive integer"
        return 1
    fi
    
    print_header "Getting Learning Material by ID"
    make_request "GET" "${BASE_URL}${ENDPOINT}/${id}" "" "Get_Learning_Material_${id}"
}

show_get_lm_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 get_learning_material -i <id>

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -i, --id    ID of the learning material to retrieve

${BOLD}EXAMPLES:${RESET}
  $0 get_learning_material -i 1
  $0 get_learning_material --id 42

EOF
    display_common_help
}

################################################################################
# UPDATE - PUT /api/learning-materials/{id}
################################################################################

update_learning_material() {
    local id=""
    local name=""
    local description=""
    local link=""
    local price=""
    local type_id=""
    local tag_ids=""
    local wiki_note_ids=""
    local notes="[]"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--id)
                id="$2"
                shift 2
                ;;
            -n|--name)
                name="$2"
                shift 2
                ;;
            -d|--description|--desc)
                description="$2"
                shift 2
                ;;
            -l|--link|--url)
                link="$2"
                shift 2
                ;;
            -p|--price)
                price="$2"
                shift 2
                ;;
            -t|--type-id|--type)
                type_id="$2"
                shift 2
                ;;
            --tag-ids|--tags)
                tag_ids="$2"
                shift 2
                ;;
            --wiki-note-ids|--wiki-notes)
                wiki_note_ids="$2"
                shift 2
                ;;
            --notes)
                notes="$2"
                shift 2
                ;;
            -h|--help)
                show_update_lm_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_update_lm_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "id" "$id"; then
        show_update_lm_help
        return 1
    fi
    
    if ! is_positive_integer "$id"; then
        print_error "ID must be a positive integer"
        return 1
    fi
    
    if ! require_arg "name" "$name"; then
        print_error "Name is required for update (the entire object must be provided)"
        show_update_lm_help
        return 1
    fi
    
    if ! require_arg "type-id" "$type_id"; then
        print_error "Type ID is required for update. Available types:"
        print_info "  2 = Book, 3 = Online Course, 4 = YouTube, 5 = Live Course"
        show_update_lm_help
        return 1
    fi
    
    # Validate numeric fields
    if ! is_positive_integer "$type_id"; then
        print_error "Type ID must be a positive integer"
        return 1
    fi
    
    if [ -n "$price" ] && ! is_integer "$price"; then
        print_error "Price must be an integer"
        return 1
    fi
    
    # Convert comma-separated IDs to JSON arrays
    local tag_ids_json="[]"
    if [ -n "$tag_ids" ]; then
        tag_ids_json=$(csv_to_json_array "$tag_ids")
    fi
    
    local wiki_note_ids_json="[]"
    if [ -n "$wiki_note_ids" ]; then
        wiki_note_ids_json=$(csv_to_json_array "$wiki_note_ids")
    fi
    
    # Validate notes JSON
    if ! is_valid_json "$notes"; then
        print_error "Notes must be valid JSON"
        return 1
    fi
    
    # Build JSON payload
    local json="{"
    json="$json\"id\":$id,\"name\":\"$name\""
    
    if [ -n "$description" ]; then
        json="$json,\"description\":\"$description\""
    else
        json="$json,\"description\":null"
    fi
    
    if [ -n "$link" ]; then
        json="$json,\"link\":\"$link\""
    else
        json="$json,\"link\":null"
    fi
    
    if [ -n "$price" ]; then
        json="$json,\"price\":$price"
    else
        json="$json,\"price\":null"
    fi
    
    json="$json,\"type\":{\"id\":$type_id}"
    json="$json,\"tagIds\":$tag_ids_json"
    json="$json,\"wikiNoteIds\":$wiki_note_ids_json"
    json="$json,\"notes\":\"$(echo "$notes" | sed 's/"/\\"/g')\""
    
    json="$json}"
    
    # Validate JSON
    if ! is_valid_json "$json"; then
        print_error "Generated invalid JSON: $json"
        return 1
    fi
    
    print_header "Updating Learning Material"
    make_request "PUT" "${BASE_URL}${ENDPOINT}/${id}" "$json" "Update_Learning_Material_${id}"
}

show_update_lm_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 update_learning_material -i <id> -n <name> -t <type_id> [options]

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -i, --id                ID of the learning material to update
  -n, --name              Name of the learning material (max 100 chars)
  -t, --type-id, --type   Type ID (2=Book, 3=Online Course, 4=YouTube, 5=Live Course)

${BOLD}OPTIONAL ARGUMENTS:${RESET}
  -d, --description       Description (null if omitted)
  -l, --link, --url       URL/link (null if omitted)
  -p, --price             Price in smallest currency unit (null if omitted)
  --tag-ids, --tags       Comma-separated tag IDs (empty array if omitted)
  --wiki-note-ids         Comma-separated wiki note IDs (empty array if omitted)
  --notes                 JSON array of notes (default: "[]")
  -h, --help              Show this help message

${BOLD}NOTE:${RESET}
  PUT requires sending the complete object. All fields not specified will be
  set to null or empty arrays (except required fields: name and type).

${BOLD}EXAMPLES:${RESET}
  # Update name only (other optional fields become null/empty)
  $0 update_learning_material -i 1 -n "Updated Name" -t 2

  # Update multiple fields
  $0 update_learning_material \\
    -i 1 \\
    -n "Spring Boot Guide" \\
    -t 2 \\
    -d "Updated description" \\
    -p 5995 \\
    --tags "1,2,3,4"

EOF
    display_common_help
}

################################################################################
# DELETE - DELETE /api/learning-materials/{id}
################################################################################

delete_learning_material() {
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
                show_delete_lm_help
                return 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_delete_lm_help
                return 1
                ;;
        esac
    done
    
    # Validate required arguments
    if ! require_arg "id" "$id"; then
        show_delete_lm_help
        return 1
    fi
    
    if ! is_positive_integer "$id"; then
        print_error "ID must be a positive integer"
        return 1
    fi
    
    # Ask for confirmation unless -y flag is provided
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Are you sure you want to delete learning material with ID $id? (yes/no)${RESET}"
        read -r response
        if [ "$response" != "yes" ] && [ "$response" != "y" ]; then
            print_info "Delete cancelled"
            return 0
        fi
    fi
    
    print_header "Deleting Learning Material"
    make_request "DELETE" "${BASE_URL}${ENDPOINT}/${id}" "" "Delete_Learning_Material_${id}"
}

show_delete_lm_help() {
    cat << EOF

${BOLD}USAGE:${RESET}
  $0 delete_learning_material -i <id> [-y]

${BOLD}REQUIRED ARGUMENTS:${RESET}
  -i, --id    ID of the learning material to delete

${BOLD}OPTIONAL ARGUMENTS:${RESET}
  -y, --yes, --confirm    Skip confirmation prompt
  -h, --help              Show this help message

${BOLD}EXAMPLES:${RESET}
  # Delete with confirmation prompt
  $0 delete_learning_material -i 1

  # Delete without confirmation
  $0 delete_learning_material -i 1 -y
  $0 delete_learning_material --id 42 --yes

EOF
    display_common_help
}

################################################################################
# Main Help
################################################################################

show_help() {
    cat << EOF

${BOLD}${CYAN}Learning Material API Testing Script${RESET}

${BOLD}USAGE:${RESET}
  $0 <function> [arguments]

${BOLD}AVAILABLE FUNCTIONS:${RESET}
  ${GREEN}create_learning_material${RESET}      Create a new learning material
  ${GREEN}get_all_learning_materials${RESET}    Get all learning materials
  ${GREEN}get_learning_material${RESET}          Get learning material by ID
  ${GREEN}update_learning_material${RESET}      Update an existing learning material
  ${GREEN}delete_learning_material${RESET}      Delete a learning material by ID
  ${GREEN}help${RESET}                          Show this help message

${BOLD}QUICK START:${RESET}
  # Get help for a specific function
  $0 create_learning_material --help

  # Create a new learning material (Book)
  $0 create_learning_material -n "Kotlin in Action" -t 2 -p 4995

  # Create with full details
  $0 create_learning_material \\
    -n "Spring Boot Guide" \\
    -t 2 \\
    -d "Complete guide" \\
    -l "https://example.com" \\
    -p 5995 \\
    --tags "1,2,3"

  # List all materials
  $0 get_all_learning_materials

  # Get specific material
  $0 get_learning_material -i 1

  # Update material
  $0 update_learning_material -i 1 -n "Updated Name" -t 2

  # Delete material
  $0 delete_learning_material -i 1 -y

${BOLD}AVAILABLE LEARNING MATERIAL TYPES:${RESET}
  ID   Name
  --   ----
  2    Book
  3    Online Course
  4    YouTube
  5    Live Course

${BOLD}TESTING WORKFLOW:${RESET}
  1. Create: $0 create_learning_material -n "Test Book" -t 2
  2. List:   $0 get_all_learning_materials
  3. Get:    $0 get_learning_material -i <id_from_create>
  4. Update: $0 update_learning_material -i <id> -n "Updated" -t 2
  5. Delete: $0 delete_learning_material -i <id> -y

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
    create|create_learning_material|create-learning-material)
        create_learning_material "$@"
        ;;
    get-all|get_all|get_all_learning_materials|list)
        get_all_learning_materials "$@"
        ;;
    get|get_learning_material|get-learning-material)
        get_learning_material "$@"
        ;;
    update|update_learning_material|update-learning-material)
        update_learning_material "$@"
        ;;
    delete|delete_learning_material|delete-learning-material)
        delete_learning_material "$@"
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
