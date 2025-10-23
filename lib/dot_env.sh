#!/usr/bin/env bash

# If SCRIPT_DIR exists use that as the base path for .env
# This defaults to having the .env file in the same directory as the script loading dot env
if [ -n "$SCRIPT_DIR" ]; then
    DOT_ENV_FILE="${DOT_ENV_FILE:-.env}"
    DOT_ENV_FILE="$SCRIPT_DIR/$DOT_ENV_FILE"
else
    DOT_ENV_FILE="${DOT_ENV_FILE:-.env}"
fi

dot_env_load () {
    if [ -f "$DOT_ENV_FILE" ]; then
        # Read the entire file and process it line by line, including the last line
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip empty lines and comments
            [[ $line =~ ^[[:space:]]*$ ]] && continue
            [[ $line =~ ^[[:space:]]*# ]] && continue
            # Remove inline comments and export
            line=$(echo "$line" | sed 's/#.*//')
            export "$line"
        done < "$DOT_ENV_FILE"
    else 
        echo "Dot Env Warning: Environment file $DOT_ENV_FILE does not exist" >&2
        return 1
    fi
}

dot_env_set(){
    key=$1
    value=$2

    if [ -z "$key" ]; then
        echo "Dot Env Error: Key is required and cannot be empty" >&2
        return 1
    fi
    
    if [ -z "$value" ]; then
        echo "Dot Env Error: Value is required and cannot be empty" >&2
        return 1
    fi
    
    # Create env file if it doesn't exist
    if [ ! -f "$DOT_ENV_FILE" ]; then
        touch "$DOT_ENV_FILE"
    fi
    
    # Check if key already exists in env file
    if grep -q "^${key}=" "$DOT_ENV_FILE"; then
        # Key exists, update it using sed (cross-platform compatible)
        sed -i.bak "s/^${key}=.*/${key}=${value}/" "$DOT_ENV_FILE" && rm -f "$DOT_ENV_FILE.bak"
        echo "Updated ${key} in $DOT_ENV_FILE"
    else
        # Key doesn't exist, add it to the end
        echo "${key}=${value}" >> "$DOT_ENV_FILE"
        echo "Added ${key} to $DOT_ENV_FILE"
    fi
    
    # Reload the environment variables
    dot_env_load
}

dot_env_unset(){
    key=$1

    if [ -z "$key" ]; then
        echo "Dot Env Error: Key is required and cannot be empty" >&2
        return 1
    fi
    
    # Check if env file exists
    if [ ! -f "$DOT_ENV_FILE" ]; then
        echo "Dot Env Error: Environment file $DOT_ENV_FILE does not exist" >&2
        return 1
    fi
    
    # Check if key exists in env file
    if ! grep -q "^${key}=" "$DOT_ENV_FILE"; then
        echo "Dot Env Error: Key '${key}' not found in $DOT_ENV_FILE" >&2
        return 1
    fi
    
    # Remove the key from the file (cross-platform compatible)
    sed -i.bak "/^${key}=/d" "$DOT_ENV_FILE" && rm -f "$DOT_ENV_FILE.bak"
    echo "Removed ${key} from $DOT_ENV_FILE"
    
    # Unset the variable from current environment
    unset "$key"
    
    # Reload the environment variables to ensure consistency
    dot_env_load
}

