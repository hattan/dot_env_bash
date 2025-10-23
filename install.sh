#!/usr/bin/env bash

set -e  # Exit on any error

# Configuration
REPO_URL="https://raw.githubusercontent.com/hattan/dot_env_bash/main"
LIB_DIR="lib"
TARGET_FILE="$LIB_DIR/dot_env.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if curl is available
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi
}

# Create lib directory if it doesn't exist
create_lib_directory() {
    if [ ! -d "$LIB_DIR" ]; then
        log_info "Creating $LIB_DIR directory..."
        mkdir -p "$LIB_DIR"
        log_success "Created $LIB_DIR directory"
    else
        log_info "$LIB_DIR directory already exists"
    fi
}

# Download the library file
download_library() {
    local url="$REPO_URL/$TARGET_FILE"
    
    log_info "Downloading dot_env.sh from $url..."
    
    if curl -fsSL "$url" -o "$TARGET_FILE"; then
        log_success "Downloaded dot_env.sh to $TARGET_FILE"
    else
        log_error "Failed to download dot_env.sh from $url"
        log_error "Please check your internet connection and try again"
        exit 1
    fi
}

# Verify the downloaded file
verify_installation() {
    if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
        # Check if the file contains expected content
        if grep -q "dot_env_load" "$TARGET_FILE" && grep -q "dot_env_set" "$TARGET_FILE"; then
            log_success "Installation verified successfully"
            return 0
        else
            log_error "Downloaded file appears to be invalid"
            return 1
        fi
    else
        log_error "Installation failed - file not found or empty"
        return 1
    fi
}

# Show usage instructions
show_usage() {
    echo ""
    echo -e "${GREEN}🎉 Bash Dot Env Library installed successfully!${NC}"
    echo ""
    echo "Usage in your scripts:"
    echo ""
    echo -e "${BLUE}#!/usr/bin/env bash${NC}"
    echo ""
    echo -e "${BLUE}# Set SCRIPT_DIR for relative path resolution${NC}"
    echo -e "${BLUE}SCRIPT_DIR=\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" &>/dev/null && pwd)${NC}"
    echo -e "${BLUE}source \"\$SCRIPT_DIR/$TARGET_FILE\"${NC}"
    echo ""
    echo -e "${BLUE}# Load environment variables${NC}"
    echo -e "${BLUE}dot_env_load${NC}"
    echo ""
    echo -e "${BLUE}# Set a variable${NC}"
    echo -e "${BLUE}dot_env_set \"API_KEY\" \"your-key-here\"${NC}"
    echo ""
    echo -e "${BLUE}# Remove a variable${NC}"
    echo -e "${BLUE}dot_env_unset \"OLD_VAR\"${NC}"
    echo ""
    echo "Documentation: https://github.com/hattan/dot_env_bash"
    echo ""
}

# Main installation function
main() {
    echo "Bash Dot Env Library Installer"
    echo "==============================="
    echo ""
    
    check_dependencies
    create_lib_directory
    download_library
    
    if verify_installation; then
        show_usage
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Handle command line arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Bash Dot Env Library Installer"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --lib-dir DIR  Specify custom lib directory (default: lib)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install to lib/dot_env.sh"
    echo "  $0 --lib-dir utils   # Install to utils/dot_env.sh"
    echo ""
    exit 0
fi

# Handle custom lib directory
if [ "$1" = "--lib-dir" ] && [ -n "$2" ]; then
    LIB_DIR="$2"
    TARGET_FILE="$LIB_DIR/dot_env.sh"
    log_info "Using custom lib directory: $LIB_DIR"
fi

# Run the installer
main