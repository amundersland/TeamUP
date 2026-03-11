#!/bin/bash
cyan "task.sh"


add_task() {
    local title=""
    local description=""
    local assigned_to=""
    local priority="MODERATE"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--title)
                title="$2"
                shift 2
                ;;
            -d|--description)
                description="$2"
                shift 2
                ;;
            -a|--assigned-to)
                assigned_to="$2"
                shift 2
                ;;
            -p|--priority)
                priority="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: add_task -t|--title <title> -d|--description <description> [-a|--assigned-to <person_id>] [-p|--priority <priority>]"
                echo "Priority values: LOW, MODERATE, IMPORTANT, URGENT"
                return 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$title" ]]; then
        echo "Error: title is required"
        echo "Usage: add_task -t|--title <title> -d|--description <description> [-a|--assigned-to <person_id>] [-p|--priority <priority>]"
        return 1
    fi
    
    if [[ -z "$description" ]]; then
        echo "Error: description is required"
        echo "Usage: add_task -t|--title <title> -d|--description <description> [-a|--assigned-to <person_id>] [-p|--priority <priority>]"
        return 1
    fi
    
    # Build JSON payload
    local json_data="{\"title\": \"$title\", \"description\": \"$description\", \"priority\": \"$priority\""
    if [[ -n "$assigned_to" ]]; then
        json_data="${json_data}, \"assignedToPerson\": $assigned_to"
    fi
    json_data="${json_data}}"
    
    # Make the API call
    curl -X POST "${HOST}/api/tasks" \
        -H "Content-Type: application/json" \
        -d "$json_data" | jq
}

get_all_tasks(){
    curl -X GET "${HOST}/api/tasks" | jq
}

get_task_with_id(){
    local id="$1"
    curl -X GET "${HOST}/api/tasks/$id" | jq
}

get_tasks_for_person(){
    local person_id="$1"
    curl -X GET "${HOST}/api/persons/$person_id/tasks" | jq
}

# If script is executed directly (not sourced), call the function with all arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    add_task "$@"
fi

echo  " $(symbol_green_checkmark)"