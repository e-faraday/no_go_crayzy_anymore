#!/bin/bash
# scripts/check-task.sh
# Mark a specific task checkbox as complete

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <task-file> <task-text>${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Create ThemeContext\""
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Add toggle to Header\""
    echo ""
    echo "Note: Task text should match the checkbox text (partial match is OK)"
    exit 1
fi

TASK_FILE=$1
TASK_TEXT="$2"

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Escape special characters for sed
ESCAPED_TEXT=$(echo "$TASK_TEXT" | sed 's/[[\.*^$()+?{|]/\\&/g' | sed 's/\\/\\\\/g' | sed 's/&/\\&/g' | sed 's|/|\\/|g')

# Find and mark the checkbox
# Look for pattern: - [ ] Task text
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    if sed -i '' "s/- \[ \] \(.*$ESCAPED_TEXT.*\)/- [x] \1/" "$TASK_FILE" 2>/dev/null; then
        # Check if actually changed
        if grep -q "- \[x\].*$TASK_TEXT" "$TASK_FILE"; then
            echo -e "${GREEN}✅ Task marked as complete:${NC} $TASK_TEXT"
        else
            echo -e "${YELLOW}⚠️  Task not found or already checked:${NC} $TASK_TEXT"
            echo ""
            echo "Searched for: $TASK_TEXT"
            echo "Try with exact text from the file."
            exit 1
        fi
    else
        echo -e "${RED}Error: Failed to update task${NC}"
        exit 1
    fi
else
    # Linux sed
    if sed -i "s/- \[ \] \(.*$ESCAPED_TEXT.*\)/- [x] \1/" "$TASK_FILE" 2>/dev/null; then
        if grep -q "- \[x\].*$TASK_TEXT" "$TASK_FILE"; then
            echo -e "${GREEN}✅ Task marked as complete:${NC} $TASK_TEXT"
        else
            echo -e "${YELLOW}⚠️  Task not found or already checked:${NC} $TASK_TEXT"
            exit 1
        fi
    else
        echo -e "${RED}Error: Failed to update task${NC}"
        exit 1
    fi
fi

echo ""
echo "Next steps:"
echo "  - Check if phase is complete: ./scripts/auto-complete-phases.sh $TASK_FILE"
echo "  - Update status: ./scripts/auto-update-status.sh $TASK_FILE"
