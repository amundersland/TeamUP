#!/bin/bash
cyan "person.sh"


add_person() {
    local name=""
    local email=""
    local age=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -e|--email)
                email="$2"
                shift 2
                ;;
            -a|--age)
                age="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: create_person -n|--name <name> [-e|--email <email>] [-a|--age <age>]"
                return 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$name" ]]; then
        echo "Error: name is required"
        echo "Usage: create_person -n|--name <name> [-e|--email <email>] [-a|--age <age>]"
        return 1
    fi
    
    # Set default email if not provided
    if [[ -z "$email" ]]; then
        email=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')
        email="${email}@bouvet.no"
    fi
    
    # Build JSON payload
    local json_data="{\"name\": \"$name\", \"email\": \"$email\""
    if [[ -n "$age" ]]; then
        json_data="${json_data}, \"age\": $age"
    fi
    json_data="${json_data}}"
    
    # Make the API call
    curl -X POST "${HOST}/api/persons" \
        -H "Content-Type: application/json" \
        -d "$json_data" | jq
}

get_all_persons(){
    curl -X GET "${HOST}/api/persons" | jq
}

get_person(){
    local id="$1"
    curl -X GET "${HOST}/api/persons/$id" | jq
}

echo  " $(symbol_green_checkmark)"