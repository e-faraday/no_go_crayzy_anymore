#!/bin/bash
# scripts/set-priority.sh
# Update task priority

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <task-file> <priority>${NC}"
    echo ""
    echo "Priority values: high, medium, low"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md high"
    echo "  $0 .claude/active/feature-add-dark-mode.md medium"
    echo "  $0 .claude/active/feature-add-dark-mode.md low"
    exit 1
fi

TASK_FILE=$1
PRIORITY=$2

# Validate priority
if [[ ! "$PRIORITY" =~ ^(high|medium|low)$ ]]; then
    echo -e "${RED}Error: Invalid priority '$PRIORITY'${NC}"
    echo "Valid priorities: high, medium, low"
    exit 1
fi

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Get current priority
CURRENT_PRIORITY=$(grep "^priority:" "$TASK_FILE" | head -1 | cut -d: -f2 | tr -d ' ')

if [ "$CURRENT_PRIORITY" = "$PRIORITY" ]; then
    echo -e "${YELLOW}⚠️  Priority is already: $PRIORITY${NC}"
    exit 0
fi

# Update priority in frontmatter
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^priority: .*/priority: $PRIORITY/" "$TASK_FILE"
else
    # Linux
    sed -i "s/^priority: .*/priority: $PRIORITY/" "$TASK_FILE"
fi

echo -e "${GREEN}✅ Priority updated${NC}"
echo ""
echo -e "${BLUE}Changed:${NC} $CURRENT_PRIORITY → $PRIORITY"
echo ""
echo "Run './scripts/daily-summary.sh' to see updated priority list."
