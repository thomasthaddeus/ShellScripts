#!/bin/bash

# Create folders with incremented numbers
for i in {1..10}; do
  folder_name=$(printf "Module%02d" $i)
  mkdir "$folder_name"
  echo "Created folder: $folder_name"

  # Create README.md file
  readme_file="$folder_name/README.md"
  touch "$readme_file"
  echo "This is README.md in $folder_name" > "$readme_file"
  echo "Created README.md in $folder_name"
done
