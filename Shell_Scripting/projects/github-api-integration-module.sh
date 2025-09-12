#!/bin/bash

######################################################################################
# Author: Chakradhar
# About This Script
#
# Purpose:
# This script is designed to interact with the GitHub API to list all users who have
# **read access (pull permission)** to a specific repository on GitHub. The script 
# takes the **repository owner** and **repository name** as arguments and uses 
# **GitHub's API** to retrieve the list of collaborators who have read access to the
# specified repository.
#
# How It Works:
# 1. **Authentication**: 
#    The script requires a **GitHub username** and a **personal access token (PAT)** 
#    for authentication. These are used to authenticate the API requests to GitHub.
#    If authentication fails (e.g., due to incorrect credentials or expired tokens), 
#    the script will return an error message indicating that the authentication has failed.
#    The personal access token should have at least **read access** to the repository you're querying.
#
# 2. **GitHub API Request**:
#    The script constructs a request URL to GitHub’s API using the **repository owner** 
#    and **repository name** provided as arguments. The URL points to the `collaborators` 
#    endpoint, which returns information about the repository's collaborators.
#    The script sends a GET request to the GitHub API to fetch the list of collaborators and 
#    their permissions (read, write, or admin).
#
# 3. **Filtering Collaborators**:
#    The response from GitHub includes detailed information about each collaborator. 
#    The script processes this response using **`jq`**, a tool for handling JSON data. 
#    It specifically looks for collaborators who have **read (pull)** permissions and 
#    extracts their **GitHub usernames**.
#
# 4. **Error Handling**:
#    The script handles different HTTP status codes returned by GitHub:
#      - **200 (OK)**: The request was successful, and the list of collaborators with read access is printed.
#      - **401 (Unauthorized)**: Authentication failed. The user is informed that their username or token is incorrect.
#      - **403 (Forbidden)**: The rate limit has been exceeded. GitHub imposes a limit on the number of API requests that can be made in a certain period. The script will ask the user to try again later.
#      - **Other errors**: Any other error will be printed along with the error details from GitHub.
#
# 5. **Temporary File Cleanup**:
#    The script stores the response from the GitHub API in a temporary file (`temp_response.json`) 
#    to process the data. The script ensures that this temporary file is deleted after the script finishes executing 
#    (even if the script encounters an error or is interrupted).
#
# 6. **Dependencies**:
#    The script requires **`jq`**, a lightweight and flexible command-line JSON processor, 
#    to parse and filter the API response. If `jq` is not installed, the script will exit with an error message 
#    and ask the user to install it.
#
# 7. **Usage**:
#    The user runs the script by providing the **repository owner** and **repository name** as arguments:
#      ```bash
#      ./script.sh <repo_owner> <repo_name>
#      ```
#    - For example:
#      ```bash
#      ./script.sh microsoft VSCode
#      ```
#    The script will then output the list of users who have read access to the `VSCode` repository owned by `microsoft`.
#
# Key Features:
# - **Authentication**: Uses GitHub username and personal access token for secure access.
# - **Error Handling**: Handles various GitHub API response codes (success, authentication failure, rate limits, etc.).
# - **Data Parsing**: Uses `jq` to filter and display users with specific read access permissions.
# - **Temporary File Cleanup**: Automatically removes temporary files to keep the system clean.
# - **User-Friendly**: Provides helpful error messages and guides for resolving issues like missing dependencies or incorrect input.
##########################################################################################################################

# GitHub API URL and authentication details
API_URL="https://api.github.com"
USERNAME=$username
TOKEN=$token

# User and Repository information from arguments
REPO_OWNER=$1
REPO_NAME=$2

# Trap to ensure temporary file is cleaned up on script exit
trap 'rm -f temp_response.json' EXIT

# Function to send a GET request to the GitHub API with authentication
github_api_get() {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send GET request with authentication details (username:token)
    response=$(curl -s -w "%{http_code}" -u "${USERNAME}:${TOKEN}" "$url" -o temp_response.json)
    http_code=$(tail -n1 <<< "$response")

    # Handle different HTTP status codes
    case "$http_code" in
        200)
            ;;
        401)
            echo "Error: Authentication failed. Check your username and token."
            cat temp_response.json
            exit 1
            ;;
        403)
            echo "Error: Rate limit exceeded. Please try again later."
            cat temp_response.json
            exit 1
            ;;
        *)
            echo "Error: GitHub API request failed with status code $http_code."
            cat temp_response.json
            exit 1
            ;;
    esac

    # Return the response body (ignoring the HTTP code)
    cat temp_response.json
}

# Function to list users with read (pull) access to the repository
list_read_access_users() {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    
    # Get the list of collaborators with their permissions
    collaborators=$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')

    # Check if there are any users with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for repository ${REPO_OWNER}/${REPO_NAME}. Ensure the repository exists and has collaborators."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to proceed."
    exit 1
fi

# Check if GitHub username and token are set
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "Error: GitHub username or token is not set. Please set them before running the script."
    exit 1
fi

# Check if repository owner and name are provided
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# Main script execution
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_read_access_users
