#!/usr/bin/env bash

# ShellSpec test for dot_env.sh library

Describe "dot_env.sh library"
  Include lib/dot_env.sh
  
  setup() {
    # Create a temporary test directory
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Set up test environment file path
    export DOT_ENV_FILE="$TEST_DIR/.env"
    
    # Create a sample .env file for testing
    cat > "$DOT_ENV_FILE" << 'EOF'
# This is a comment
APP_NAME=TestApp
API_KEY="secret-key-123"
PORT=3000
DEBUG=true # Inline comment
EMPTY_LINE_BELOW=value

# Another comment
DB_HOST=localhost
DB_PORT=5432
QUOTED_VALUE="value with spaces"
SPECIAL_CHARS=value@#$%
EOF
  }
  
  cleanup() {
    # Clean up test directory
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
      rm -rf "$TEST_DIR"
    fi
    
    # Clean up environment variables
    unset APP_NAME API_KEY PORT DEBUG EMPTY_LINE_BELOW DB_HOST DB_PORT QUOTED_VALUE SPECIAL_CHARS
    unset TEST_VAR NEW_VAR UPDATED_VAR
  }
  
  BeforeEach "setup"
  AfterEach "cleanup"

  Describe "dot_env_load function"
    It "loads environment variables from .env file"
      When call dot_env_load
      The status should be success
      The variable APP_NAME should equal "TestApp"
      The variable API_KEY should equal "secret-key-123"
      The variable PORT should equal "3000"
      The variable DEBUG should equal "true"
    End

    It "handles quoted values correctly"
      When call dot_env_load
      The status should be success
      The variable QUOTED_VALUE should equal "value with spaces"
    End

    It "handles special characters in values"
      When call dot_env_load
      The status should be success
      The variable SPECIAL_CHARS should equal "value@#$%"
    End

    It "skips comment lines"
      When call dot_env_load
      The status should be success
      # Should not create variables for comments
      The variable "This" should be undefined
    End

    It "handles inline comments"
      When call dot_env_load
      The status should be success
      The variable DEBUG should equal "true"
      The variable DEBUG should not include "# Inline comment"
    End

    It "returns error when .env file doesn't exist"
      rm -f "$DOT_ENV_FILE"
      When call dot_env_load
      The status should be failure
      The stderr should include "does not exist"
    End

    It "handles files without trailing newlines"
      echo -n "NO_NEWLINE=value" > "$DOT_ENV_FILE"
      When call dot_env_load
      The status should be success
      The variable NO_NEWLINE should equal "value"
    End
  End

  Describe "dot_env_set function"
    It "sets a new environment variable"
      dot_env_load
      When call dot_env_set "TEST_VAR" "test_value"
      The status should be success
      The variable TEST_VAR should equal "test_value"
      The output should include "Added TEST_VAR"
    End

    It "updates an existing environment variable"
      dot_env_load
      When call dot_env_set "APP_NAME" "UpdatedApp"
      The status should be success
      The variable APP_NAME should equal "UpdatedApp"
      The output should include "Updated APP_NAME"
    End

    It "persists changes to .env file"
      dot_env_load
      dot_env_set "NEW_VAR" "new_value"
      # Reload and check if variable persists
      unset NEW_VAR
      When call dot_env_load
      The variable NEW_VAR should equal "new_value"
    End

    It "creates .env file if it doesn't exist"
      rm -f "$DOT_ENV_FILE"
      When call dot_env_set "FIRST_VAR" "first_value"
      The status should be success
      The file "$DOT_ENV_FILE" should be exist
      The contents of file "$DOT_ENV_FILE" should include "FIRST_VAR=first_value"
    End

    It "returns error when key is empty"
      When call dot_env_set "" "value"
      The status should be failure
      The stderr should include "Key is required"
    End

    It "returns error when value is empty"
      When call dot_env_set "KEY" ""
      The status should be failure
      The stderr should include "Value is required"
    End

    It "returns error when key is missing"
      When call dot_env_set
      The status should be failure
      The stderr should include "Key is required"
    End

    It "handles values with spaces"
      When call dot_env_set "SPACED_VAR" "value with spaces"
      The status should be success
      The variable SPACED_VAR should equal "value with spaces"
    End

    It "handles special characters in values"
      When call dot_env_set "SPECIAL_VAR" "value@#$%^&*()"
      The status should be success
      The variable SPECIAL_VAR should equal "value@#$%^&*()"
    End
  End

  Describe "dot_env_unset function"
    It "removes an existing environment variable"
      dot_env_load
      dot_env_set "TEMP_VAR" "temp_value"
      When call dot_env_unset "TEMP_VAR"
      The status should be success
      The variable TEMP_VAR should be undefined
      The output should include "Removed TEMP_VAR"
    End

    It "removes variable from .env file"
      dot_env_load
      dot_env_set "TO_REMOVE" "remove_me"
      dot_env_unset "TO_REMOVE"
      # Reload and check if variable is gone
      When call dot_env_load
      The variable TO_REMOVE should be undefined
    End

    It "returns error when key doesn't exist"
      dot_env_load
      When call dot_env_unset "NONEXISTENT_KEY"
      The status should be failure
      The stderr should include "not found"
    End

    It "returns error when .env file doesn't exist"
      rm -f "$DOT_ENV_FILE"
      When call dot_env_unset "ANY_KEY"
      The status should be failure
      The stderr should include "does not exist"
    End

    It "returns error when key is empty"
      When call dot_env_unset ""
      The status should be failure
      The stderr should include "Key is required"
    End

    It "returns error when key is missing"
      When call dot_env_unset
      The status should be failure
      The stderr should include "Key is required"
    End
  End

  Describe "DOT_ENV_FILE configuration"
    It "uses custom DOT_ENV_FILE path"
      custom_env="$TEST_DIR/custom.env"
      echo "CUSTOM_VAR=custom_value" > "$custom_env"
      export DOT_ENV_FILE="$custom_env"
      
      # Need to re-source the library with new DOT_ENV_FILE
      Include lib/dot_env.sh
      
      When call dot_env_load
      The status should be success
      The variable CUSTOM_VAR should equal "custom_value"
    End

    It "works with SCRIPT_DIR when set"
      # Create a subdirectory and set SCRIPT_DIR
      mkdir -p "$TEST_DIR/subdir"
      export SCRIPT_DIR="$TEST_DIR/subdir"
      echo "SCRIPT_DIR_VAR=script_value" > "$TEST_DIR/subdir/.env"
      
      # Re-source with SCRIPT_DIR set
      unset DOT_ENV_FILE
      Include lib/dot_env.sh
      
      When call dot_env_load
      The status should be success
      The variable SCRIPT_DIR_VAR should equal "script_value"
    End
  End

  Describe "Integration tests"
    It "performs complete workflow: load, set, unset"
      # Load initial variables
      dot_env_load
      original_app_name="$APP_NAME"
      
      # Set a new variable
      dot_env_set "WORKFLOW_VAR" "workflow_value"
      
      # Update existing variable
      dot_env_set "APP_NAME" "WorkflowApp"
      
      # Verify changes
      The variable WORKFLOW_VAR should equal "workflow_value"
      The variable APP_NAME should equal "WorkflowApp"
      
      # Remove the new variable
      dot_env_unset "WORKFLOW_VAR"
      
      # Verify removal
      When call echo "$WORKFLOW_VAR"
      The output should be blank
      
      # Verify other variables still exist
      The variable APP_NAME should equal "WorkflowApp"
      The variable API_KEY should equal "secret-key-123"
    End

    It "handles edge cases with whitespace and empty lines"
      cat > "$DOT_ENV_FILE" << 'EOF'

   
# Comment with spaces
   SPACED_KEY=spaced_value   
NORMAL_KEY=normal_value

   # Another spaced comment   

EOF
      When call dot_env_load
      The status should be success
      The variable SPACED_KEY should equal "spaced_value   "
      The variable NORMAL_KEY should equal "normal_value"
    End
  End
End