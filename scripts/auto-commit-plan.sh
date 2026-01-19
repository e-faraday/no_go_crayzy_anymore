#!/bin/bash
# scripts/auto-commit-plan.sh
# Automatically commit when a plan is completed

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <task-file> <plan-name>${NC}"
    echo ""
    echo "Automatically commits when a plan is completed."
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Plan 1\""
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Plan 1: Setup\""
    exit 1
fi

TASK_FILE=$1
PLAN_NAME="$2"

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Check if git repo exists
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not a git repository, skipping commit${NC}"
    exit 0
fi

# Extract feature slug from filename
BASENAME=$(basename "$TASK_FILE" .md)
FEATURE_SLUG=$(echo "$BASENAME" | sed 's/^feature-//')

# Extract plan number from plan name (e.g., "Plan 1" -> "1")
PLAN_NUM=$(echo "$PLAN_NAME" | grep -oE "Plan [0-9]+" | grep -oE "[0-9]+" | head -1)
if [ -z "$PLAN_NUM" ]; then
    # Try to extract from format "Plan 1: Setup"
    PLAN_NUM=$(echo "$PLAN_NAME" | sed 's/^Plan //' | cut -d: -f1 | tr -d ' ')
fi

# Extract plan name without "Plan N:" prefix
PLAN_NAME_CLEAN=$(echo "$PLAN_NAME" | sed 's/^Plan [0-9]*: *//' | sed 's/^Plan [0-9]* *//')

# Count completed tasks in this plan
PLAN_HEADER=$(grep -n "^#### Plan $PLAN_NUM" "$TASK_FILE" | head -1)
if [ -z "$PLAN_HEADER" ]; then
    echo -e "${YELLOW}⚠️  Plan $PLAN_NUM not found${NC}"
    exit 1
fi

PLAN_LINE=$(echo "$PLAN_HEADER" | cut -d: -f1)
NEXT_PLAN_LINE=$(grep -n "^#### Plan" "$TASK_FILE" | awk -F: -v current="$PLAN_LINE" '$1 > current {print $1; exit}')
if [ -z "$NEXT_PLAN_LINE" ]; then
    NEXT_SECTION_LINE=$(grep -n "^### ✅ Acceptance Criteria\|^### 📝 Progress Log\|^### 🔖 Current Checkpoint" "$TASK_FILE" | head -1 | cut -d: -f1)
    if [ -z "$NEXT_SECTION_LINE" ]; then
        PLAN_END=$(wc -l < "$TASK_FILE")
    else
        PLAN_END=$((NEXT_SECTION_LINE - 1))
    fi
else
    PLAN_END=$((NEXT_PLAN_LINE - 1))
fi

TOTAL_TASKS=$(sed -n "${PLAN_LINE},${PLAN_END}p" "$TASK_FILE" | grep -c "^- \[" 2>/dev/null || echo "0")
CHECKED_TASKS=$(sed -n "${PLAN_LINE},${PLAN_END}p" "$TASK_FILE" | grep -c "^- \[x\]" 2>/dev/null || echo "0")

# Get list of completed tasks
COMPLETED_TASKS=$(sed -n "${PLAN_LINE},${PLAN_END}p" "$TASK_FILE" | grep "^- \[x\]" | sed 's/^- \[x\] //' | head -5)

# Check if file has uncommitted changes
if git diff --quiet "$TASK_FILE" 2>/dev/null && git diff --cached --quiet "$TASK_FILE" 2>/dev/null; then
    echo -e "${BLUE}ℹ️  No changes to commit${NC}"
    exit 0
fi

# Stage the task file
git add "$TASK_FILE"

# Create commit message
COMMIT_MSG="docs($FEATURE_SLUG): complete Plan $PLAN_NUM: $PLAN_NAME_CLEAN

Tasks completed: $CHECKED_TASKS/$TOTAL_TASKS"

# Add task list if available
if [ -n "$COMPLETED_TASKS" ]; then
    COMMIT_MSG="$COMMIT_MSG
$(echo "$COMPLETED_TASKS" | sed 's/^/- /')"
fi

# Commit
if git commit -m "$COMMIT_MSG" > /dev/null 2>&1; then
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo -e "${GREEN}✅ Committed:${NC} docs($FEATURE_SLUG): complete Plan $PLAN_NUM"
    echo -e "${BLUE}   Commit:${NC} $COMMIT_HASH"
else
    echo -e "${YELLOW}⚠️  Commit failed (may be empty or already committed)${NC}"
    exit 0
fi
