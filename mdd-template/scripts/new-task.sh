#!/bin/bash
# scripts/new-task.sh
# Create a new task from template

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <type> <title>${NC}"
    echo ""
    echo "Types: feature, bug, refactor, decision"
    echo ""
    echo "Examples:"
    echo "  $0 feature \"Add dark mode\""
    echo "  $0 bug \"Login fails on Safari\""
    echo "  $0 refactor \"Simplify auth logic\""
    echo "  $0 decision \"Choose state management\""
    exit 1
fi

TYPE=$1
TITLE=$2

# Validate type
if [[ ! "$TYPE" =~ ^(feature|bug|refactor|decision)$ ]]; then
    echo -e "${RED}Error: Invalid type '$TYPE'${NC}"
    echo "Valid types: feature, bug, refactor, decision"
    exit 1
fi

# Check if title is empty
if [ -z "$TITLE" ]; then
    echo -e "${RED}Error: Title cannot be empty${NC}"
    echo ""
    echo "Usage: $0 <type> <title>"
    echo ""
    echo "Examples:"
    echo "  $0 feature \"Add dark mode\""
    echo "  $0 bug \"Login fails on Safari\""
    exit 1
fi

# Create slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
FILE=".claude/active/${TYPE}-${SLUG}.md"

# Check if file already exists
if [ -f "$FILE" ]; then
    echo -e "${YELLOW}Warning: File already exists: $FILE${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 1
    fi
fi

# Create .claude/active directory if it doesn't exist
mkdir -p .claude/active

# Copy template
TEMPLATE=".claude/templates/${TYPE}.md"
if [ ! -f "$TEMPLATE" ]; then
    echo -e "${RED}Error: Template not found: $TEMPLATE${NC}"
    exit 1
fi

cp "$TEMPLATE" "$FILE"

# Escape special characters in TITLE for sed replacement string
# In sed replacement string, only &, \, and delimiter (/) need escaping
# Order matters: escape backslash first, then ampersand, then forward slash
ESCAPED_TITLE=$(echo "$TITLE" | sed 's/\\/\\\\/g' | sed 's/&/\\&/g' | sed 's|/|\\/|g')

# Replace placeholders
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/YYYY-MM-DD/$DATE/g" "$FILE"
    sed -i '' "s/HH:MM/$TIME/g" "$FILE"
    sed -i '' "s/\[Name\]/$ESCAPED_TITLE/g" "$FILE"
    sed -i '' "s/\[Description\]/$ESCAPED_TITLE/g" "$FILE"
    sed -i '' "s/\[What\]/$ESCAPED_TITLE/g" "$FILE"
    sed -i '' "s/\[Topic\]/$ESCAPED_TITLE/g" "$FILE"
else
    # Linux
    sed -i "s/YYYY-MM-DD/$DATE/g" "$FILE"
    sed -i "s/HH:MM/$TIME/g" "$FILE"
    sed -i "s/\[Name\]/$ESCAPED_TITLE/g" "$FILE"
    sed -i "s/\[Description\]/$ESCAPED_TITLE/g" "$FILE"
    sed -i "s/\[What\]/$ESCAPED_TITLE/g" "$FILE"
    sed -i "s/\[Topic\]/$ESCAPED_TITLE/g" "$FILE"
fi

echo -e "${GREEN}✅ Created: $FILE${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit the file to add details"
echo "  2. Start working: claude"
echo "  3. Reference it: @$FILE implement this"
echo ""

# Open in editor if available (skip if NO_EDITOR is set)
if [ -z "$NO_EDITOR" ]; then
    if command -v code &> /dev/null; then
        code "$FILE"
    elif command -v vim &> /dev/null; then
        vim "$FILE"
    else
        echo "Open $FILE in your editor to get started"
    fi
fi
