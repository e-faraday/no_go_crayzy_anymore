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
AUTO_COMMIT=false
if [ "$1" = "--auto-commit" ]; then
    AUTO_COMMIT=true
    shift
fi

if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 [--auto-commit] <task-file> <task-text-or-number>${NC}"
    echo ""
    echo "Options:"
    echo "  --auto-commit    Automatically commit after marking task complete"
    echo ""
    echo "Examples:"
    echo "  # Using task text (partial match OK):"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Create ThemeContext\""
    echo "  $0 --auto-commit .claude/active/feature-add-dark-mode.md \"ThemeContext\""
    echo ""
    echo "  # Using task number (Plan.Task format):"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"1.1\""
    echo "  $0 --auto-commit .claude/active/feature-add-dark-mode.md \"2.3\""
    echo ""
    echo "Note: Task number format is Plan.Task (e.g., 1.1 = Plan 1, Task 1)"
    echo "Note: Task text should match the checkbox text (partial match is OK)"
    echo "Note: AUTO_COMMIT=true environment variable also enables auto-commit"
    exit 1
fi

TASK_FILE=$1
TASK_TEXT="$2"

# Check for AUTO_COMMIT environment variable
if [ "$AUTO_COMMIT" = "false" ] && [ "$AUTO_COMMIT" != "true" ]; then
    if [ "$AUTO_COMMIT" = "true" ] || [ "${AUTO_COMMIT:-false}" = "true" ]; then
        AUTO_COMMIT=true
    fi
fi

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Function to parse task number (e.g., "1.1" → plan=1, task=1)
parse_task_number() {
    local input="$1"
    if [[ "$input" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
        PLAN_NUM="${BASH_REMATCH[1]}"
        TASK_NUM="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

# Function to find task by number in a plan
find_task_by_number() {
    local file="$1"
    local plan_num="$2"
    local task_num="$3"
    
    # Find the plan section (supports both "Plan N:" and "Phase N:" formats)
    local plan_start_line=$(grep -nE "^#### (Plan|Phase) $plan_num:" "$file" | head -1 | cut -d: -f1)
    
    if [ -z "$plan_start_line" ]; then
        return 1  # Plan not found
    fi
    
    # Find the end of this plan (next plan or Acceptance Criteria section)
    local plan_end_line=$(sed -n "$plan_start_line,\$p" "$file" | grep -nE "^#### (Plan|Phase) |^### (✅ Acceptance Criteria|📝 Progress Log|🔖 Current Checkpoint)" | sed -n '2p' | cut -d: -f1)
    
    if [ -n "$plan_end_line" ]; then
        plan_end_line=$((plan_start_line + plan_end_line - 1))
    else
        plan_end_line=$(wc -l < "$file")
    fi
    
    # Count unchecked tasks in this plan
    local unchecked_count=0
    local target_line=""
    
    while IFS= read -r line_num; do
        local line_content=$(sed -n "${line_num}p" "$file")
        if [[ "$line_content" =~ ^-[[:space:]]\[[[:space:]]\] ]]; then
            unchecked_count=$((unchecked_count + 1))
            if [ "$unchecked_count" -eq "$task_num" ]; then
                target_line="$line_num"
                break
            fi
        fi
    done < <(seq "$plan_start_line" "$plan_end_line")
    
    if [ -n "$target_line" ]; then
        echo "$target_line"
        return 0
    fi
    
    return 1  # Task number not found
}

# Check if input is a task number
USE_TASK_NUMBER=false
PLAN_NUM=""
TASK_NUM=""

if parse_task_number "$TASK_TEXT"; then
    USE_TASK_NUMBER=true
    TASK_LINE=$(find_task_by_number "$TASK_FILE" "$PLAN_NUM" "$TASK_NUM")
    
    if [ -z "$TASK_LINE" ]; then
        echo -e "${RED}Error: Task $PLAN_NUM.$TASK_NUM not found in Plan $PLAN_NUM${NC}"
        echo ""
        echo "Plan $PLAN_NUM may not exist or task number $TASK_NUM is out of range."
        exit 1
    fi
    
    # Get the actual task text for display and commit
    TASK_ACTUAL_TEXT=$(sed -n "${TASK_LINE}p" "$TASK_FILE" | sed 's/^- \[ \] //' | sed 's/^- \[x\] //')
    
    # Mark the checkbox at the specific line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "${TASK_LINE}s/^- \[ \]/- [x]/" "$TASK_FILE"
    else
        sed -i "${TASK_LINE}s/^- \[ \]/- [x]/" "$TASK_FILE"
    fi
    
    # Verify it was marked
    if grep -q "^- \[x\]" <<< "$(sed -n "${TASK_LINE}p" "$TASK_FILE")"; then
        echo -e "${GREEN}✅ Task $PLAN_NUM.$TASK_NUM marked as complete:${NC} $TASK_ACTUAL_TEXT"
        TASK_TEXT="$TASK_ACTUAL_TEXT"  # Update for commit message
    else
        # Check if already checked
        if grep -q "^- \[x\]" <<< "$(sed -n "${TASK_LINE}p" "$TASK_FILE")"; then
            echo -e "${YELLOW}⚠️  Task $PLAN_NUM.$TASK_NUM is already checked:${NC} $TASK_ACTUAL_TEXT"
        else
            echo -e "${RED}Error: Failed to mark task $PLAN_NUM.$TASK_NUM${NC}"
            exit 1
        fi
    fi
fi

# If not using task number, use existing text matching logic
if [ "$USE_TASK_NUMBER" = "false" ]; then
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
                echo "Try with exact text from the file or use task number format (e.g., 1.1)."
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
                echo ""
                echo "Try with exact text from the file or use task number format (e.g., 1.1)."
                exit 1
            fi
        else
            echo -e "${RED}Error: Failed to update task${NC}"
            exit 1
        fi
    fi
fi

# Auto-commit if requested
if [ "$AUTO_COMMIT" = "true" ] || [ "${AUTO_COMMIT:-false}" = "true" ]; then
    if [ -f "./scripts/auto-commit-task.sh" ]; then
        echo ""
        ./scripts/auto-commit-task.sh "$TASK_FILE" "$TASK_TEXT" 2>/dev/null || true
    fi
fi

echo ""
echo "Next steps:"
echo "  - Check if phase is complete: ./scripts/auto-complete-phases.sh $TASK_FILE"
echo "  - Update status: ./scripts/auto-update-status.sh $TASK_FILE"
if [ "$AUTO_COMMIT" != "true" ] && [ "${AUTO_COMMIT:-false}" != "true" ]; then
    echo "  - Auto-commit: $0 --auto-commit $TASK_FILE \"$TASK_TEXT\""
fi