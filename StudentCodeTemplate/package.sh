#!/bin/bash

# Default values for variables
TYPE=""
MAIN=""
OUTPUT_DIR="Swift Coding Environment.swiftpm"

# Function to show usage instructions
usage() {
  echo "Usage: $0 --type <turtle|text> [--main <main_file>]"
  exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --type)
      TYPE=$2
      shift 2
      ;;
    --main)
      MAIN=$2
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      usage
      ;;
  esac
done

# Validate type argument
if [[ -z "$TYPE" ]]; then
  echo "Error: --type argument is required."
  usage
fi

if [[ "$TYPE" != "turtle" && "$TYPE" != "text" ]]; then
  echo "Error: --type must be either 'turtle' or 'text'."
  usage
fi

# Create the output directory
mkdir -p "$OUTPUT_DIR/Support Code"

# Copy necessary files
cp -r "Support Code/"* "$OUTPUT_DIR/Support Code/"
cp "Packaging/Package.txt" "$OUTPUT_DIR/Package.swift"
cp "Packaging/ResolvedPackage.txt" "$OUTPUT_DIR/Package.resolved"
cp "arrow.png" "$OUTPUT_DIR/Support Code/"

# Handle the type-specific files
if [ "$TYPE" == "turtle" ]; then
  cp "Packaging/TurtleMain.txt" "$OUTPUT_DIR/Main.swift"
  cp "Packaging/TurtleApp.txt" "$OUTPUT_DIR/Support Code/App.swift"
  cp -r "Turtle Support/"* "$OUTPUT_DIR/Support Code/"
elif [ "$TYPE" == "text" ]; then
  cp "Packaging/TextMain.txt" "$OUTPUT_DIR/Main.swift"
  cp "Packaging/TextApp.txt" "$OUTPUT_DIR/Support Code/App.swift"
  cp -r "Text Support/"* "$OUTPUT_DIR/Support Code/"

fi

# If 'main' argument is provided, override Main.swift
if [ -n "$MAIN" ]; then
  if [ -f "$MAIN" ]; then
    cp "$MAIN" "$OUTPUT_DIR/Main.swift"
  else
    echo "Warning: Main file '$MAIN' not found. Skipping override."
  fi
fi

echo "Files successfully prepared in the '$OUTPUT_DIR' directory."
