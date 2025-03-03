#!/usr/bin/env bash

# Function to display the help message
show_help() {
    echo "Usage: $0 <directory>"
    echo "Create symbolic links in the current working directory for all files in the specified directory."
    echo
    echo "Arguments:"
    echo "  <directory>  The directory containing files to link."
}

# Check if the first argument is provided
if [ -z "$1" ]; then
    show_help
    exit 1
fi

# Assign the first argument to a variable
dir="$1"

# Check if the directory exists
if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
fi

# Initialize the counter
count=0

# Loop through all files in the directory
for file in "$dir"/*; do
    # Check if it's a file
    if [ -f "$file" ]; then
        # Get the filename
        filename=$(basename "$file")
        # Create a symbolic link in the current working directory
        ln -sf "$file" "$filename"
        # Increment the counter
        count=$((count + 1))
    fi
done

echo "Created $count symbolic links in the current directory."
