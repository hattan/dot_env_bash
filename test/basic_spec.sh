#!/usr/bin/env bash

# Basic functionality tests for dot_env.sh
# Include the library at the top level
Include lib/dot_env.sh

Describe "dot_env.sh basic functionality"
  
  setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR" || return 1
    export DOT_ENV_FILE="$TEST_DIR/.env"
  }
  
  cleanup() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
      rm -rf "$TEST_DIR"
    fi
    unset TEST_VAR APP_NAME API_KEY PORT DEBUG DOT_ENV_FILE
  }
  
  BeforeEach "setup"
  AfterEach "cleanup"

  Describe "dot_env_load function"
    It "loads simple environment variables"
      echo "TEST_VAR=test_value" > "$DOT_ENV_FILE"
      When call dot_env_load
      The status should be success
      The variable TEST_VAR should equal "test_value"
    End

    It "skips comment lines"
      cat > "$DOT_ENV_FILE" << 'EOF'
# This is a comment
TEST_VAR=test_value
# Another comment
EOF
      When call dot_env_load
      The status should be success
      The variable TEST_VAR should equal "test_value"
    End

    It "handles inline comments"
      echo "TEST_VAR=test_value # inline comment" > "$DOT_ENV_FILE"
      When call dot_env_load
      The status should be success
      The variable TEST_VAR should equal "test_value "
    End

    It "returns error when file doesn't exist"
      rm -f "$DOT_ENV_FILE"
      When call dot_env_load
      The status should be failure
      The stderr should include "does not exist"
    End
  End

  Describe "dot_env_set function"
    It "sets a new variable"
      When call dot_env_set "TEST_VAR" "test_value"
      The status should be success
      The variable TEST_VAR should equal "test_value"
      The stdout should include "Added TEST_VAR"
    End

    It "returns error for empty key"
      When call dot_env_set "" "value"
      The status should be failure
      The stderr should include "Key is required"
    End

    It "returns error for empty value"
      When call dot_env_set "KEY" ""
      The status should be failure
      The stderr should include "Value is required"
    End
  End

  Describe "dot_env_unset function"
    It "removes an existing variable"
      echo "TEST_VAR=test_value" > "$DOT_ENV_FILE"
      dot_env_load
      When call dot_env_unset "TEST_VAR"
      The status should be success
      The stdout should include "Removed TEST_VAR"
    End

    It "returns error for non-existent key"
      echo "OTHER_VAR=value" > "$DOT_ENV_FILE"
      When call dot_env_unset "NONEXISTENT"
      The status should be failure
      The stderr should include "not found"
    End

    It "returns error for empty key"
      When call dot_env_unset ""
      The status should be failure
      The stderr should include "Key is required"
    End
  End
End