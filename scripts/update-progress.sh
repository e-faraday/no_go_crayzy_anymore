#!/bin/bash
# scripts/update-progress.sh
# Add entry to Progress Log

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <task-file> <message> [task-number]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Phase 1 completed\""
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Fixed bug in theme toggle\""
    echo "  $0 .claude/active/feature-add-dark-mode.md \"All components styled for dark mode\""
    echo ""
    echo "  # With task number (Plan.Task format):"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Task completed\" \"1.1\""
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Bug fixed\" \"2.3\""
    echo ""
    echo "Note: Task number format is Plan.Task (e.g., 1.1 = Plan 1, Task 1)"
    exit 1
fi

TASK_FILE=$1
MESSAGE="$2"
TASK_NUMBER="$3"

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Get date and time
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

# Format progress log entry
if [ -n "$TASK_NUMBER" ]; then
    # Validate task number format
    if [[ ! "$TASK_NUMBER" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid task number format: $TASK_NUMBER${NC}"
        echo "Task number should be in Plan.Task format (e.g., 1.1, 2.3)"
        exit 1
    fi
    LOG_ENTRY="**$DATE $TIME** - [Task $TASK_NUMBER] $MESSAGE"
else
    LOG_ENTRY="**$DATE $TIME** - $MESSAGE"
fi

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

echo -e "${GREEN}✅ Progress Log updated${NC}"
echo ""
echo -e "${BLUE}Added:${NC} $LOG_ENTRY"
