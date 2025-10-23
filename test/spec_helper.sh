#!/usr/bin/env bash

# Test helper functions for dot_env.sh tests

# Create a test .env file with standard content
create_test_env() {
    local env_file="${1:-.env}"
    cat > "$env_file" << 'EOF'
# Test environment file
APP_NAME=TestApp
API_KEY="secret-key-123"
PORT=3000
DEBUG=true # Inline comment
DB_HOST=localhost
QUOTED_VALUE="value with spaces"
SPECIAL_CHARS=value@#$%
EOF
}

# Create a minimal test .env file
create_minimal_env() {
    local env_file="${1:-.env}"
    cat > "$env_file" << 'EOF'
SIMPLE_VAR=simple_value
ANOTHER_VAR=another_value
EOF
}

# Create an .env file with edge cases
create_edge_case_env() {
    local env_file="${1:-.env}"
    cat > "$env_file" << 'EOF'
# Comments and edge cases

   SPACED_KEY=spaced_value   
NORMAL_KEY=normal_value

   # Spaced comment   
EQUALS_IN_VALUE=key=value=test
EMPTY_VALUE=
# COMMENTED_OUT=should_not_load
LAST_LINE_NO_NEWLINE=value_without_newline
EOF
    # Remove the last newline to test edge case
    printf "LAST_LINE_NO_NEWLINE=value_without_newline" > "$env_file.tmp"
    cat "$env_file" | head -n -1 > "$env_file.tmp2"
    cat "$env_file.tmp2" > "$env_file"
    printf "LAST_LINE_NO_NEWLINE=value_without_newline" >> "$env_file"
    rm -f "$env_file.tmp" "$env_file.tmp2"
}

# Clean up test environment variables
cleanup_test_vars() {
    unset APP_NAME API_KEY PORT DEBUG DB_HOST QUOTED_VALUE SPECIAL_CHARS
    unset SIMPLE_VAR ANOTHER_VAR SPACED_KEY NORMAL_KEY EQUALS_IN_VALUE EMPTY_VALUE
    unset LAST_LINE_NO_NEWLINE TEST_VAR NEW_VAR UPDATED_VAR TEMP_VAR TO_REMOVE
    unset WORKFLOW_VAR CUSTOM_VAR SCRIPT_DIR_VAR FIRST_VAR SPACED_VAR SPECIAL_VAR
}

# Assert that a variable is set and has expected value
assert_var_equals() {
    local var_name="$1"
    local expected_value="$2"
    local actual_value
    
    # Use indirect variable expansion
    actual_value="${!var_name}"
    
    if [ "$actual_value" = "$expected_value" ]; then
        return 0
    else
        echo "Expected $var_name='$expected_value', got '$actual_value'" >&2
        return 1
    fi
}

# Assert that a variable is not set
assert_var_unset() {
    local var_name="$1"
    local actual_value
    
    # Use indirect variable expansion
    actual_value="${!var_name}"
    
    if [ -z "$actual_value" ]; then
        return 0
    else
        echo "Expected $var_name to be unset, but it has value '$actual_value'" >&2
        return 1
    fi
}

# Create a temporary directory for tests
setup_test_dir() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    echo "$TEST_DIR"
}

# Clean up temporary test directory
cleanup_test_dir() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        unset TEST_DIR
    fi
}