#!/bin/bash

# Script to set up markdown tooling in a repository
# Adds markdown tools to scripts directory and makes them executable

set -e

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    REPO_ROOT="."
fi

# Make all markdown scripts executable
find "$REPO_ROOT/scripts/markdown" -name "*.sh" -type f -exec chmod +x {} \;

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "pre-commit is not installed. Please install it with:"
    echo "pip install pre-commit"
    exit 1
fi

# Create the pre-commit config if it doesn't exist
if [ ! -f "$REPO_ROOT/.pre-commit-config.yaml" ]; then
    echo "Creating .pre-commit-config.yaml..."
    cat > "$REPO_ROOT/.pre-commit-config.yaml" << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.34.0
    hooks:
      - id: markdownlint
        name: Check markdown formatting
        args: [--config, .markdownlint.json]

  - repo: https://github.com/adrienverge/yamllint.git
    rev: v1.30.0
    hooks:
      - id: yamllint
        args: [--config-file, .yamllint.yml]

  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.9.0
    hooks:
      - id: shellcheck

  - repo: local
    hooks:
      - id: fix-markdown-comprehensive
        name: Fix common markdown issues comprehensively
        entry: ./scripts/markdown/fix_markdown_comprehensive.sh
        language: script
        pass_filenames: false
        verbose: true

      - id: fix-list-numbering
        name: Fix ordered list numbering
        entry: ./scripts/markdown/fix_list_numbering.sh
        language: script
        pass_filenames: false
        verbose: true

      - id: fix-heading-levels
        name: Fix markdown heading levels
        entry: ./scripts/markdown/fix_heading_levels.sh
        language: script
        pass_filenames: false
        verbose: true

      - id: markdownlint-fix
        name: Fix remaining markdown issues with markdownlint
        entry: bash -c 'markdownlint --fix "**/*.md" --ignore node_modules'
        language: system
        pass_filenames: false
        types: [markdown]
        verbose: true
EOF
else
    echo ".pre-commit-config.yaml already exists. Please manually add markdown hooks if needed."
fi

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
cd "$REPO_ROOT" || exit
pre-commit install

echo "Markdown tools setup complete!"
echo "You can now run 'pre-commit run --all-files' to fix markdown formatting"