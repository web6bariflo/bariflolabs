#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the raw API response
    response="$(github_api_get "$endpoint")"

    # Check if the response is a valid array (collaborators list)
    if echo "$response" | jq -e 'type == "array"' > /dev/null; then
        collaborators="$(echo "$response" | jq -r '.[] | select(.permissions.pull == true) | .login')"
        
        if [[ -z "$collaborators" ]]; then
            echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
        else
            echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
            echo "$collaborators"
        fi
    else
        # Likely an error message from GitHub
        echo "Failed to retrieve collaborators. Response:"
        echo "$response" | jq .
    fi
}


# Main script

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access

