#!/bin/bash

# Script to fix heading levels in markdown files
# Ensures headings start at level 1 (# Title) rather than level 2 or greater
# Does not modify readme files that are intentionally structured differently

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    REPO_ROOT="."
fi

find "$REPO_ROOT" -name "*.md" -type f | while read -r file; do
    # Skip README files which often have different heading structures
    if [[ "$file" == *"README.md"* ]] || [[ "$file" == *"/readme.md"* ]]; then
        echo "Skipping README file: $file"
        continue
    fi
    
    echo "Processing $file for heading levels"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # First, determine the minimum heading level used in the file
    min_level=$(grep -E "^#+[ \t]+" "$file" | sed -E 's/^(#+)[ \t]+.*/\1/' | awk '{ print length($0) }' | sort -n | head -1)
    
    if [ -z "$min_level" ] || [ "$min_level" -eq 1 ]; then
        # No headings or already starts with level 1, no adjustment needed
        cat "$file" > "$temp_file"
    else
        # Adjustment needed - subtract (min_level - 1) from all heading levels
        adjustment=$((min_level - 1))
        
        awk -v adj="$adjustment" '
        BEGIN {
            in_code_block = 0;
        }
        
        # Handle code blocks - no modifications inside
        /^```/ {
            in_code_block = !in_code_block;
            print;
            next;
        }
        
        # Inside code blocks, do not modify
        in_code_block {
            print;
            next;
        }
        
        # Heading detection and adjustment
        /^#+[ \t]+/ {
            # Extract the heading markers and the content
            match($0, /^(#+)([ \t]+.*)/, parts);
            
            if (length(parts) >= 3) {
                current_level = length(parts[1]);
                new_level = current_level - adj;
                
                # Ensure we have at least one # for level 1
                if (new_level < 1) new_level = 1;
                
                # Print the adjusted heading
                printf "%s%s\n", substr("######", 1, new_level), parts[2];
            } else {
                print;
            }
            next;
        }
        
        # Default - print the line as is
        {
            print;
        }
        ' "$file" > "$temp_file"
    fi
    
    # Replace the original file with the fixed one
    mv "$temp_file" "$file"
done

echo "Heading levels fixed"