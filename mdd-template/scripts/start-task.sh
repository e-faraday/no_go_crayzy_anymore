#!/bin/bash
# scripts/start-task.sh
# Start working on a task (auto-update to in-progress)

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 1 ]; then
    echo -e "${RED}Usage: $0 <task-file> [message]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-user-authentication.md"
    echo "  $0 .claude/active/feature-add-user-authentication.md \"Starting Phase 1\""
    exit 1
fi

TASK_FILE=$1
MESSAGE=${2:-"Started working on this task"}

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Get current status
CURRENT_STATUS=$(grep "^status:" "$TASK_FILE" | head -1 | cut -d: -f2 | tr -d ' ')

# Check if already in-progress
if [ "$CURRENT_STATUS" = "in-progress" ]; then
    echo -e "${YELLOW}⚠️  Task is already in-progress${NC}"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Update status in frontmatter
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^status: .*/status: in-progress/" "$TASK_FILE"
else
    # Linux
    sed -i "s/^status: .*/status: in-progress/" "$TASK_FILE"
fi

# Update status at bottom if exists
if grep -q "^\*\*Status:\*\*" "$TASK_FILE" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^\*\*Status:\*\* .*/\*\*Status:\*\* In Progress/" "$TASK_FILE"
    else
        sed -i "s/^\*\*Status:\*\* .*/\*\*Status:\*\* In Progress/" "$TASK_FILE"
    fi
fi

# Get date and time
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

# Add progress log entry
LOG_ENTRY="**$DATE $TIME** - $MESSAGE"

# Check if Progress Log section exists
if grep -q "### 📝 Progress Log" "$TASK_FILE"; then
    # Find the line after "### 📝 Progress Log"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "/^### 📝 Progress Log$/a\\
\\
$LOG_ENTRY
" "$TASK_FILE"
    else
        # Linux sed
        sed -i "/^### 📝 Progress Log$/a\\\n$LOG_ENTRY" "$TASK_FILE"
    fi
else
    # If Progress Log section doesn't exist, add it before Current Checkpoint
    if grep -q "### 🔖 Current Checkpoint" "$TASK_FILE"; then
        PROGRESS_SECTION="### 📝 Progress Log\\
\\
$LOG_ENTRY\\
\\
### 🔖 Current Checkpoint"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/^### 🔖 Current Checkpoint$/i\\
$PROGRESS_SECTION
" "$TASK_FILE"
        else
            sed -i "/^### 🔖 Current Checkpoint$/i\\$PROGRESS_SECTION" "$TASK_FILE"
        fi
    else
        # If neither exists, add at the end before final status
        PROGRESS_SECTION="\\
\\
### 📝 Progress Log\\
\\
$LOG_ENTRY"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "\$i\\
$PROGRESS_SECTION
" "$TASK_FILE"
        else
            echo -e "\n$PROGRESS_SECTION" >> "$TASK_FILE"
        fi
    fi
fi

echo -e "${GREEN}✅ Task started!${NC}"
echo ""
echo -e "${BLUE}Status updated:${NC} in-progress"
echo -e "${BLUE}Progress Log:${NC} $LOG_ENTRY"
echo ""
echo "Next steps:"
echo "  1. Start working: claude"
echo "  2. Reference it: @$TASK_FILE implement this"
echo ""
