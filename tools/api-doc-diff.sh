#!/bin/bash

# Script to compare Mist API documentation files between two git tags
# Usage: api-doc-diff.sh <path> <from_tag> <to_tag>

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Function to print warning messages
warn() {
    echo -e "${YELLOW}WARNING: $1${NC}" >&2
}

# Function to print success messages
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print usage
usage() {
    echo "Usage: $0 <path> <from_tag> <to_tag>"
    echo ""
    echo "Arguments:"
    echo "  path      Path to the Mist API repository"
    echo "  from_tag  Git tag to compare from"
    echo "  to_tag    Git tag to compare to"
    echo ""
    echo "Example:"
    echo "  $0 /path/to/api v1.0.0 v1.1.0"
    exit 1
}

# Check if all parameters are provided
if [ $# -ne 3 ]; then
    error "Missing required parameters"
    usage
fi

API_PATH="$1"
FROM_TAG="$2"
TO_TAG="$3"

# Store original directory
ORIGINAL_DIR=$(pwd)

# Validate that path exists
if [ ! -d "$API_PATH" ]; then
    error "Path does not exist: $API_PATH"
    exit 1
fi

# Change to the API repository
cd "$API_PATH" || {
    error "Failed to change directory to: $API_PATH"
    exit 1
}

# Validate that it's a git repository
if [ ! -d .git ]; then
    error "Not a git repository: $API_PATH"
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Validate that the tags exist
if ! git rev-parse "$FROM_TAG" >/dev/null 2>&1; then
    error "Tag does not exist: $FROM_TAG"
    cd "$ORIGINAL_DIR"
    exit 1
fi

if ! git rev-parse "$TO_TAG" >/dev/null 2>&1; then
    error "Tag does not exist: $TO_TAG"
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Create timestamp (YYYYMMDD format)
TIMESTAMP=$(date +%Y%m%d)

# Create temporary directory structure
TEMP_BASE="/tmp/api-doc-diff/${TIMESTAMP}"
FROM_DIR="${TEMP_BASE}/${FROM_TAG}"
TO_DIR="${TEMP_BASE}/${TO_TAG}"

echo "Creating temporary directories..."
mkdir -p "$FROM_DIR"
mkdir -p "$TO_DIR"

# List of files to extract
FILES=(
    "docs/src/Home.md"
    "docs/src/Overview.md"
    "docs/src/Auth.md"
    "docs/src/Site.md"
    "docs/src/Org.md"
    "docs/src/MSP.md"
)

# Function to extract file from a tag
extract_file() {
    local tag=$1
    local filepath=$2
    local dest_dir=$3
    local filename=$(basename "$filepath")
    
    if git cat-file -e "${tag}:${filepath}" 2>/dev/null; then
        git show "${tag}:${filepath}" > "${dest_dir}/${filename}"
        echo "  ✓ Extracted: $filename"
    else
        warn "File does not exist in tag $tag: $filepath"
        # Create empty placeholder file
        touch "${dest_dir}/${filename}.missing"
    fi
}

# Extract files from FROM tag
echo ""
success "Extracting files from tag: $FROM_TAG"
for file in "${FILES[@]}"; do
    extract_file "$FROM_TAG" "$file" "$FROM_DIR"
done

# Extract files from TO tag
echo ""
success "Extracting files from tag: $TO_TAG"
for file in "${FILES[@]}"; do
    extract_file "$TO_TAG" "$file" "$TO_DIR"
done

# Print location of extracted files
echo ""
success "Files extracted successfully!"
echo ""
echo "Location: $TEMP_BASE"
echo "  - $FROM_TAG files: $FROM_DIR"
echo "  - $TO_TAG files: $TO_DIR"
echo ""

# Open VS Code with the temp directory
echo "Opening VS Code..."
code "$TEMP_BASE"

# Return to original directory
cd "$ORIGINAL_DIR" || {
    error "Failed to return to original directory"
    exit 1
}

success "Done!"
