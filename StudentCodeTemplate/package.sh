#!/bin/bash

# Default values for variables
TYPE=""
MAIN=""
NAME=""

# Function to show usage instructions
usage() {
  echo "Usage: $0 --type <turtle|text> [--main <main_file> --name <package_name>]"
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
    --name)
      NAME=$2
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

if [[ "$NAME" == "" ]]; then
    NAME="Swift Coding Environment"
fi

OUTPUT_DIR="$NAME.swiftpm"
# Create the output directory
mkdir -p "$OUTPUT_DIR/Support Code"

# Copy necessary files
cp -r "Support Code/"* "$OUTPUT_DIR/Support Code/"
sed "s/{{PACKAGE_NAME}}/$NAME/g" "Packaging/Package.txt" > "$OUTPUT_DIR/Package.swift"
cp "Packaging/ResolvedPackage.txt" "$OUTPUT_DIR/Package.resolved"

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
