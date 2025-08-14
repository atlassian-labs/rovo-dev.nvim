.PHONY: test test-verbose lint format docs clean help

# Configuration
LUA_PATH ?= lua/
TEST_PATH ?= test/
DOC_PATH ?= doc/

# Test command (runs only Plenary tests by default)
test:
	@echo "Running Plenary tests..."
	@nvim --headless -u tests/minimal_init.lua \
	  -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }" \
	  -c 'qa!'

# Verbose tests
test-verbose:
	@echo "Running Plenary tests (verbose)..."
	@PLENARY_BUSTED_VERBOSE=1 nvim --headless -u tests/minimal_init.lua \
	  -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }" \
	  -c 'qa!'


# Lint Lua files
lint:
	@echo "Linting Lua files..."
	@luacheck $(LUA_PATH)

# Format Lua files with stylua
format:
	@echo "Formatting Lua files..."
	@stylua $(LUA_PATH)

# Generate documentation
docs:
	@echo "Generating documentation..."
	@if command -v ldoc > /dev/null 2>&1; then \
		ldoc $(LUA_PATH) -d $(DOC_PATH)luadoc -c .ldoc.cfg || true; \
	else \
		echo "ldoc not installed. Skipping documentation generation."; \
	fi

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(DOC_PATH)luadoc

# Default target
all: lint format test docs

help:
	@echo "Rovo Dev development commands:"
	@echo "  make test           - Run specs with plenary.busted"
	@echo "  make test-verbose   - Run specs with verbose output"
	@echo "  make lint           - Lint Lua files (luacheck)"
	@echo "  make format         - Format Lua files with stylua"
	@echo "  make docs           - Generate documentation (ldoc if available)"
	@echo "  make clean          - Remove generated files"
	@echo "  make all            - Run lint, format, test, and docs"
