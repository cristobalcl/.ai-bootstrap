#!/bin/bash

# Script to create symbolic links based on requirements/links.txt

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LINKS_FILE="$PROJECT_ROOT/requirements/links.txt"

# Check if links.txt exists
if [[ ! -f "$LINKS_FILE" ]]; then
    echo "Error: $LINKS_FILE not found"
    exit 1
fi

# Process each line in links.txt
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Split line into source and destination
    source_path=$(echo "$line" | awk '{print $1}')
    dest_path=$(echo "$line" | awk '{print $2}')
    
    # Skip if source or destination is empty
    [[ -z "$source_path" || -z "$dest_path" ]] && continue
    
    # Resolve source path relative to project root
    if [[ "$source_path" = /* ]]; then
        full_source="$source_path"
    else
        full_source="$PROJECT_ROOT/$source_path"
    fi
    
    # Resolve destination path (expand ~ and handle relative paths)
    dest_path_expanded="${dest_path/#\~/$HOME}"
    
    # Create destination directory if it doesn't exist
    dest_dir="$(dirname "$dest_path_expanded")"
    if [[ ! -d "$dest_dir" ]]; then
        echo "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi
    
    # Create symbolic link
    if [[ -e "$dest_path_expanded" ]]; then
        echo "Warning: $dest_path_expanded already exists, skipping"
    else
        echo "Creating link: $full_source -> $dest_path_expanded"
        ln -s "$full_source" "$dest_path_expanded"
    fi
    
done < "$LINKS_FILE"

echo "Link creation complete"