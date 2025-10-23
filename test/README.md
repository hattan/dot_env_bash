# Test Documentation

This directory contains comprehensive tests for the Bash Dot Env Library using [ShellSpec](https://shellspec.info/).

## Test Structure

```
test/
├── basic_spec.sh      # Basic functionality tests
├── dot_env_spec.sh    # Comprehensive test suite
├── spec_helper.sh     # Test helper functions
└── README.md          # This file
```

## Running Tests

### Prerequisites

The tests use ShellSpec, which will be automatically installed when you run the tests:

```bash
# Run all tests (installs ShellSpec if needed)
make test

# Or run ShellSpec directly
shellspec
```

### Test Commands

```bash
# Run basic tests only
make test-basic

# Run all tests
make test

# Run tests with verbose output
make test-verbose

# Run tests with coverage (if available)
make test-coverage

# Install ShellSpec manually
make install-shellspec
```

## Test Coverage

The test suite covers:

### `dot_env_load` function
- ✅ Loading simple environment variables
- ✅ Handling comment lines (both full-line and inline)
- ✅ Processing quoted values
- ✅ Managing special characters
- ✅ Handling files without trailing newlines
- ✅ Error handling for missing files
- ✅ Whitespace and empty line handling

### `dot_env_set` function
- ✅ Setting new environment variables
- ✅ Updating existing variables
- ✅ Persisting changes to file
- ✅ Creating .env file if it doesn't exist
- ✅ Input validation (empty keys/values)
- ✅ Handling special characters and spaces
- ✅ File format preservation

### `dot_env_unset` function
- ✅ Removing existing variables
- ✅ Cleaning up from both file and environment
- ✅ Error handling for non-existent keys
- ✅ Input validation
- ✅ File integrity after removal

### Configuration
- ✅ Custom `DOT_ENV_FILE` paths
- ✅ `SCRIPT_DIR` integration
- ✅ Environment variable precedence

### Integration Tests
- ✅ Complete workflows (load → set → unset)
- ✅ Edge cases and error conditions
- ✅ File format preservation
- ✅ Environment consistency

## Test Files

### `basic_spec.sh`
Contains fundamental tests for core functionality. Good for quick validation.

### `dot_env_spec.sh`
Comprehensive test suite covering all features, edge cases, and error conditions.

### `spec_helper.sh`
Utility functions for creating test environments and assertions.

## Writing Tests

ShellSpec uses a BDD (Behavior Driven Development) style syntax:

```bash
Describe "Feature being tested"
  It "should behave in a specific way"
    When call function_name "argument"
    The status should be success
    The variable SOME_VAR should equal "expected_value"
  End
End
```

### Common Patterns

```bash
# Test successful function execution
When call dot_env_load
The status should be success

# Test variable values
The variable APP_NAME should equal "TestApp"

# Test error conditions
When call dot_env_set "" "value"
The status should be failure
The stderr should include "Key is required"

# Test file contents
The contents of file ".env" should include "KEY=value"
```

## Continuous Integration

To integrate with CI/CD systems:

```yaml
# GitHub Actions example
- name: Run tests
  run: |
    make install-shellspec
    make test
```

```bash
# Simple CI script
#!/bin/bash
set -e
make install-shellspec
make test
echo "All tests passed!"
```

## Debugging Tests

### Run specific test files
```bash
shellspec test/basic_spec.sh
```

### Run with verbose output
```bash
shellspec --format tap
```

### Debug a specific test
```bash
shellspec --focus-filter "loads simple environment variables"
```

### Check test coverage
```bash
make test-coverage
```

## Test Environment

Each test runs in isolation with:
- Temporary test directories
- Clean environment variables
- Separate .env files
- Proper cleanup after each test

This ensures tests don't interfere with each other and can run in any order.

## Adding New Tests

1. Choose the appropriate test file (`basic_spec.sh` for simple tests, `dot_env_spec.sh` for comprehensive tests)
2. Follow the existing patterns
3. Include both positive and negative test cases
4. Add setup/cleanup as needed
5. Test edge cases and error conditions

Example:
```bash
It "handles new feature correctly"
  # Setup
  echo "TEST_VAR=value" > "$DOT_ENV_FILE"
  Include lib/dot_env.sh
  
  # Execute
  When call new_function "parameter"
  
  # Assert
  The status should be success
  The output should include "expected output"
End
```