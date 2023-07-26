#!/bin/bash

# Get the current directory of the script
SCRIPT_DIR=$(dirname "$0")

# Define a function to rename directories recursively
rename_directories() {
  local dir="$1"
  local new_dir="${dir//THM-}"
  
  # Rename the current directory
  if [[ "$dir" != "$new_dir" ]]; then
    mv -v "$dir" "$new_dir"
  fi
  
  # Process subdirectories
  for sub_dir in "$new_dir"/*; do
    if [[ -d "$sub_dir" ]]; then
      rename_directories "$sub_dir"
    fi
  done
}

# Call the function to start renaming directories
rename_directories "$SCRIPT_DIR"
