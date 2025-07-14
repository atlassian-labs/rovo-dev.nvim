#!/bin/bash

# Script to fix ordered list numbering in markdown files
# Finds all ordered lists using 1. format and ensures they are consecutively numbered

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    REPO_ROOT="."
fi

find "$REPO_ROOT" -name "*.md" -type f | while read -r file; do
    echo "Processing $file for ordered list numbering"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Process the file with awk
    awk '
    BEGIN {
        in_list = 0;
        list_number = 0;
        in_code_block = 0;
    }
    
    # Handle code blocks - we do not modify content inside code blocks
    /^```/ {
        in_code_block = !in_code_block;
        print;
        next;
    }
    
    # Inside code blocks, do not modify anything
    in_code_block {
        print;
        next;
    }
    
    # End of list conditions
    /^$/ && in_list {
        in_list = 0;
        list_number = 0;
        print;
        next;
    }
    
    # Not in a list and not starting a list - just print the line
    !/^[ \t]*[0-9]+\.[ \t]+/ && !in_list {
        print;
        next;
    }
    
    # Start of list or continuation of list
    /^[ \t]*[0-9]+\.[ \t]+/ {
        # Extract indentation and content
        match($0, /^([ \t]*)[0-9]+\.[ \t]+(.*)/, parts);
        
        # If not in a list, this is the start of a new list
        if (!in_list) {
            in_list = 1;
            list_number = 1;
        } else {
            # We are continuing an existing list, increment the counter
            list_number++;
        }
        
        # Print the line with the correct number
        if (length(parts) >= 3) {
            printf "%s%d. %s\n", parts[1], list_number, parts[2];
        } else {
            # If the regex did not match correctly (should not happen), print as is
            print;
        }
        next;
    }
    
    # Not an ordered list item, but we are in a list
    # This could be blank lines within a list or other content
    in_list {
        print;
        next;
    }
    
    # Default - just print the line
    {
        print;
    }
    ' "$file" > "$temp_file"
    
    # Replace the original file with the fixed one
    mv "$temp_file" "$file"
done

echo "Ordered list numbering fixed"