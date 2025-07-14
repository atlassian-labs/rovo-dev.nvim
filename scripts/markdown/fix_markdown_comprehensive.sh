#!/bin/bash

# Comprehensive markdown fixer that addresses common linting issues:
# 1. Ensure blank lines around headings (MD022)
# 2. Ensure blank lines around lists (MD032)
# 3. Fix missing language specifiers in code blocks (MD040)
# 4. Ensure blank lines around fenced code blocks (MD031)
# 5. Fix emphasis used as heading (MD036)
# 6. Ensure files end with newline (MD047)

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    REPO_ROOT="."
fi

find "$REPO_ROOT" -name "*.md" -type f | while read -r file; do
    echo "Processing $file for comprehensive markdown fixes"

    # Create a temporary file
    temp_file=$(mktemp)

    # Use awk to handle multi-line operations and fix multiple issues at once
    awk '
    # Initialize variables
    BEGIN {
        in_code_block = 0;
        last_line_type = "text"; # Can be: text, heading, list, empty, code_start, code_end
        empty_line_count = 0;
    }

    # Function to determine if a line needs blank lines around it
    function needs_blank_line(line_type) {
        return (line_type == "heading" || line_type == "list" || line_type == "code_start" || line_type == "code_end");
    }

    # Empty line detection
    /^[ \t]*$/ {
        if (last_line_type == "empty") {
            empty_line_count++;
            if (empty_line_count > 1) {
                # Skip duplicate empty lines
                next;
            }
        } else {
            empty_line_count = 1;
        }

        print "";
        last_line_type = "empty";
        next;
    }

    # Reset empty line counter for non-empty lines
    {
        empty_line_count = 0;
    }

    # Heading detection
    /^#+[ \t]+/ {
        # Ensure blank line before heading if not already there
        if (last_line_type != "empty" && last_line_type != "BEGIN") {
            print "";
        }

        # Print the heading
        print $0;

        # Mark that we just processed a heading
        last_line_type = "heading";
        next;
    }

    # List item detection
    /^[ \t]*[-*+][ \t]+/ || /^[ \t]*[0-9]+\.[ \t]+/ {
        # Ensure blank line before list if previous line was not a list item or empty line
        if (last_line_type != "empty" && last_line_type != "list" && last_line_type != "BEGIN") {
            print "";
        }

        # Print the list item
        print $0;

        # Mark that we just processed a list item
        last_line_type = "list";
        next;
    }

    # Code block start detection
    /^```/ {
        in_code_block = 1;

        # Ensure blank line before code block if not already there
        if (last_line_type != "empty" && last_line_type != "BEGIN") {
            print "";
        }

        # Add language specifier if missing
        if ($0 == "```") {
            print "```text";
        } else {
            print $0;
        }

        last_line_type = "code_start";
        next;
    }

    # Code block end detection
    in_code_block && /^```$/ {
        in_code_block = 0;

        # Print the code block end
        print $0;

        # Ensure blank line after code block
        print "";

        last_line_type = "code_end";
        next;
    }

    # Fix emphasis used as heading (*Last updated: date* -> ### Last updated: date)
    !in_code_block && /^\*[^*]+\*$/ && ($0 ~ /Last [Uu]pdated/ || $0 ~ /Last [Aa]rchived/) {
        # Convert emphasis to heading
        sub(/^\*/, "### ");
        sub(/\*$/, "");

        # Ensure blank line before heading if not already there
        if (last_line_type != "empty" && last_line_type != "BEGIN") {
            print "";
        }

        # Print the converted heading
        print $0;

        last_line_type = "heading";
        next;
    }

    # Default case - print the line as is
    {
        print $0;
        last_line_type = "text";
    }

    # Ensure file ends with exactly one newline
    END {
        if (last_line_type != "empty") {
            print "";
        }
    }
    ' "$file" > "$temp_file"

    # Replace the original file with the fixed one
    mv "$temp_file" "$file"
done

echo "Comprehensive Markdown fixing complete"