#!/bin/bash
# scripts/auto-update-status.sh
# Automatically update task status based on checkbox completion

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 1 ]; then
    echo -e "${RED}Usage: $0 <task-file>${NC}"
    echo ""
    echo "Automatically updates task status based on checkbox completion:"
    echo "  - All checkboxes checked → completed"
    echo "  - Some checkboxes checked → in-progress"
    echo "  - No checkboxes checked → todo"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md"
    exit 1
fi

TASK_FILE=$1

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Get current status
CURRENT_STATUS=$(grep "^status:" "$TASK_FILE" | head -1 | cut -d: -f2 | tr -d ' ')

# Count total checkboxes and checked ones
TOTAL_CHECKBOXES=$(grep -c "^- \[" "$TASK_FILE" 2>/dev/null || echo "0")
CHECKED_CHECKBOXES=$(grep -c "^- \[x\]" "$TASK_FILE" 2>/dev/null || echo "0")

# Ensure numeric values
TOTAL_CHECKBOXES=$(echo "$TOTAL_CHECKBOXES" | tr -d '[:space:]')
CHECKED_CHECKBOXES=$(echo "$CHECKED_CHECKBOXES" | tr -d '[:space:]')
TOTAL_CHECKBOXES=${TOTAL_CHECKBOXES:-0}
CHECKED_CHECKBOXES=${CHECKED_CHECKBOXES:-0}

UNCHECKED_CHECKBOXES=$((TOTAL_CHECKBOXES - CHECKED_CHECKBOXES))

# Determine new status
if [ "$TOTAL_CHECKBOXES" -eq 0 ]; then
    NEW_STATUS="todo"
    REASON="No checkboxes found"
elif [ "$CHECKED_CHECKBOXES" -eq "$TOTAL_CHECKBOXES" ] && [ "$TOTAL_CHECKBOXES" -gt 0 ]; then
    NEW_STATUS="completed"
    REASON="All $TOTAL_CHECKBOXES checkboxes are checked"
elif [ "$CHECKED_CHECKBOXES" -gt 0 ]; then
    NEW_STATUS="in-progress"
    REASON="$CHECKED_CHECKBOXES of $TOTAL_CHECKBOXES checkboxes checked"
else
    NEW_STATUS="todo"
    REASON="No checkboxes checked"
fi

# Update status if changed
if [ "$CURRENT_STATUS" = "$NEW_STATUS" ]; then
    echo -e "${BLUE}ℹ️  Status is already:${NC} $NEW_STATUS"
    echo "  $REASON"
    exit 0
fi

# Update status in frontmatter
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^status: .*/status: $NEW_STATUS/" "$TASK_FILE"
else
    # Linux
    sed -i "s/^status: .*/status: $NEW_STATUS/" "$TASK_FILE"
fi

# Update status at bottom if exists
if grep -q "^\*\*Status:\*\*" "$TASK_FILE" 2>/dev/null; then
    STATUS_TEXT=$(echo "$NEW_STATUS" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^\*\*Status:\*\* .*/\*\*Status:\*\* $STATUS_TEXT/" "$TASK_FILE"
    else
        sed -i "s/^\*\*Status:\*\* .*/\*\*Status:\*\* $STATUS_TEXT/" "$TASK_FILE"
    fi
fi

echo -e "${GREEN}✅ Status updated${NC}"
echo ""
echo -e "${BLUE}Changed:${NC} $CURRENT_STATUS → $NEW_STATUS"
echo -e "${BLUE}Reason:${NC} $REASON"
echo ""
if [ "$TOTAL_CHECKBOXES" -gt 0 ]; then
    echo "Checkbox status: $CHECKED_CHECKBOXES/$TOTAL_CHECKBOXES checked"
else
    echo "No checkboxes found in task"
fi
