# Makefile for dot_env.sh project

.PHONY: test test-basic test-full install-shellspec clean help

# Default target
all: test

# Install ShellSpec if not available
install-shellspec:
	@if ! command -v shellspec >/dev/null 2>&1; then \
		echo "Installing ShellSpec..."; \
		curl -fsSL https://git.io/shellspec | sh -s -- --yes; \
		export PATH="$$HOME/.local/bin:$$PATH"; \
	else \
		echo "ShellSpec is already installed"; \
	fi

# Run basic tests
test-basic: install-shellspec
	@echo "Running basic tests..."
	shellspec test/basic_spec.sh

# Run all tests
test: install-shellspec
	@echo "Running all tests..."
	shellspec

# Run tests with coverage (if shellspec-coverage is available)
test-coverage: install-shellspec
	@echo "Running tests with coverage..."
	shellspec --coverage || shellspec

# Run tests in verbose mode
test-verbose: install-shellspec
	@echo "Running tests in verbose mode..."
	shellspec --format tap

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	rm -rf coverage/
	rm -f .shellspec-quick.log

# Show help
help:
	@echo "Available targets:"
	@echo "  test          - Run all tests"
	@echo "  test-basic    - Run basic tests only"
	@echo "  test-coverage - Run tests with coverage"
	@echo "  test-verbose  - Run tests in verbose mode"
	@echo "  install-shellspec - Install ShellSpec testing framework"
	@echo "  clean         - Clean up test artifacts"
	@echo "  help          - Show this help message"

# Example usage targets
example-load:
	@echo "Running load example..."
	./example/load.sh

example-set:
	@echo "Running set example..."
	./example/set.sh "test_value"

example-unset:
	@echo "Running unset example..."
	./example/unset.sh

examples: example-load example-set example-unset