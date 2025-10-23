# Bash Dot Env Library

A lightweight, pure Bash library for loading, setting, and managing environment variables from `.env` files. This library handles comments, inline comments, quoted values, and files without trailing newlines.

## Features

- 🚀 **Load environment variables** from `.env` files
- ✏️ **Set/Update variables** programmatically and persist to file
- 🗑️ **Remove variables** from both file and current environment
- 💬 **Comment support** - handles both full-line and inline comments
- 📁 **Configurable file paths** - use custom `.env` file locations
- 🔧 **Robust parsing** - handles files without trailing newlines
- ⚡ **Zero dependencies** - pure Bash implementation

## Installation

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/hattan/dot_env_bash/main/install.sh | bash
```

### Manual Installation

Simply source the library in your script:

```bash
# Set SCRIPT_DIR to enable relative path resolution
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/dot_env.sh"
```

## Quick Start

1. Create a `.env` file in your project root:
```bash
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME="my_app"
DB_USER=admin # This is a comment

# API Keys
API_KEY=your_secret_key_here
DEBUG=true
```

2. Load variables in your script:
```bash
#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/dot_env.sh"

# Load all variables from .env
dot_env_load

# Use the variables
echo "Connecting to $DB_HOST:$DB_PORT"
echo "Database: $DB_NAME"
```

## Running the Examples

You can test the library immediately using the provided examples:

```bash
# Clone or download this repository
cd /path/to/dotenv

# Run the basic load example
./example/load.sh
```

**Expected output:**
```
ARM_SUBSCRIPTION_ID="123123-12312-123123-123"
ARM_AAAAI="2222-2222-2222-2222"
ARM_TENANT_ID=5555-5555-555-555
COUNT=2
FOO=new_value
```

This demonstrates loading all variables from the `.env` file in the project root. Try the other examples:

```bash
# Test setting a variable
./example/set.sh "updated_value"

# Test removing a variable  
./example/unset.sh

# Test using a custom environment file
./example/custom_env_file.sh
```

## API Reference

### `dot_env_load`

Loads all environment variables from the configured `.env` file.

```bash
dot_env_load
```

**Features:**
- Skips empty lines and comment lines (starting with `#`)
- Handles inline comments (removes everything after `#`)
- Exports variables to current shell environment
- Handles files without trailing newlines
- Returns error if file doesn't exist

**Example:**
```bash
dot_env_load
if [ $? -ne 0 ]; then
    echo "Failed to load .env file"
    exit 1
fi
```

### `dot_env_set`

Sets or updates an environment variable both in the current environment and the `.env` file.

```bash
dot_env_set <key> <value>
```

**Parameters:**
- `key` - Variable name (required)
- `value` - Variable value (required)

**Features:**
- Creates `.env` file if it doesn't exist
- Updates existing keys or adds new ones
- Automatically reloads environment after changes
- Provides feedback on whether key was added or updated

**Examples:**
```bash
# Set a new variable
dot_env_set "API_URL" "https://api.example.com"

# Update existing variable
dot_env_set "DEBUG" "false"

# Set variable with spaces (value will be unquoted in file)
dot_env_set "APP_NAME" "My Application"
```

### `dot_env_unset`

Removes an environment variable from both the current environment and the `.env` file.

```bash
dot_env_unset <key>
```

**Parameters:**
- `key` - Variable name to remove (required)

**Features:**
- Validates that key exists before removal
- Removes from both file and current environment
- Automatically reloads remaining environment variables
- Provides clear error messages for missing keys/files

**Examples:**
```bash
# Remove a variable
dot_env_unset "OLD_API_KEY"

# Handle errors
if ! dot_env_unset "SOME_VAR"; then
    echo "Variable not found or other error occurred"
fi
```

## Configuration

### Custom Environment File

By default, the library looks for `.env` in the current directory (or relative to `SCRIPT_DIR` if set). You can override this:

```bash
# Set custom file path before sourcing
DOT_ENV_FILE="/path/to/custom.env"
source "lib/dot_env.sh"

# Or set it relative to script directory
DOT_ENV_FILE="config/production.env"
```

### Script Directory Integration

If you set `SCRIPT_DIR`, the library will look for `.env` relative to that directory:

```bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/dot_env.sh"
# Will look for .env in the same directory as your script
```

## Environment File Format

The library supports a flexible `.env` format:

```bash
# Comments are ignored
# Empty lines are also ignored

# Simple key-value pairs
DATABASE_URL=postgres://localhost/mydb
PORT=3000

# Quoted values (quotes are preserved)
APP_NAME="My Application"
SECRET_KEY='very-secret-key'

# Inline comments
DEBUG=true # Set to false in production
API_TIMEOUT=30 # seconds

# Values with special characters
REDIS_URL=redis://user:pass@localhost:6379/0

# Environment-specific variables
NODE_ENV=development
```

**Supported features:**
- Full-line comments (lines starting with `#`)
- Inline comments (everything after `#` is ignored)
- Quoted and unquoted values
- Empty lines (ignored)
- Files without trailing newlines

## Examples

### Basic Usage

```bash
#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/dot_env.sh"

# Load environment
dot_env_load

# Use variables
echo "Starting server on port $PORT"
echo "Database: $DATABASE_URL"
```

### Dynamic Configuration

```bash
#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/dot_env.sh"

# Load initial config
dot_env_load

# Update configuration based on environment
if [ "$NODE_ENV" = "production" ]; then
    dot_env_set "DEBUG" "false"
    dot_env_set "LOG_LEVEL" "warn"
else
    dot_env_set "DEBUG" "true"
    dot_env_set "LOG_LEVEL" "debug"
fi

echo "Debug mode: $DEBUG"
echo "Log level: $LOG_LEVEL"
```

### Environment-Specific Files

```bash
#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Choose environment file
ENVIRONMENT=${ENVIRONMENT:-development}
DOT_ENV_FILE="$SCRIPT_DIR/.env.$ENVIRONMENT"

source "$SCRIPT_DIR/lib/dot_env.sh"

echo "Loading environment: $ENVIRONMENT"
echo "From file: $DOT_ENV_FILE"

dot_env_load
```

### Cleanup Old Variables

```bash
#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/dot_env.sh"

dot_env_load

# Remove deprecated variables
dot_env_unset "OLD_API_ENDPOINT"
dot_env_unset "LEGACY_TOKEN"

# Set new variables
dot_env_set "NEW_API_ENDPOINT" "https://api.v2.example.com"
```

## Error Handling

All functions return appropriate exit codes and write errors to stderr:

```bash
# Check if load was successful
if ! dot_env_load; then
    echo "Failed to load environment file" >&2
    exit 1
fi

# Check if set operation succeeded
if ! dot_env_set "KEY" "value"; then
    echo "Failed to set variable" >&2
    exit 1
fi

# Check if unset operation succeeded
if ! dot_env_unset "KEY"; then
    echo "Failed to unset variable (may not exist)" >&2
    # Continue execution - this might be expected
fi
```

## Project Structure

```
.
├── lib/
│   └── dot_env.sh          # Main library file
├── example/
│   ├── load.sh             # Basic loading example
│   ├── set.sh              # Setting variables example
│   ├── unset.sh            # Removing variables example
│   └── custom_env_file.sh  # Custom file path example
├── test/
│   ├── basic_spec.sh       # Basic functionality tests
│   ├── dot_env_spec.sh     # Comprehensive test suite
│   ├── spec_helper.sh      # Test utilities
│   └── README.md           # Testing documentation
├── install.sh              # Automated installation script
├── Taskfile.yml            # Task runner configuration
├── .shellspec              # ShellSpec test configuration
├── .env                    # Example environment file
└── README.md               # This file
```

## Development

### Running Tests

```bash
# Install task runner (if not already installed)
curl -sL https://taskfile.dev/install.sh | sh

# Run all tests
task test

# Run basic tests only
task test-basic

# Run examples
task examples

# Show all available tasks
task help
```

## Requirements

- Bash 4.0+ (for regex support)
- Standard Unix utilities: `grep`, `sed`

## Contributing

Feel free to submit issues and pull requests to improve this library.

## License

This project is released under the MIT License.