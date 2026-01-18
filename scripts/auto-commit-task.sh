#!/bin/bash
# scripts/auto-commit-task.sh
# Automatically commit when a single task (checkbox) is completed

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <task-file> <task-name>${NC}"
    echo ""
    echo "Automatically commits a single completed task."
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Create ThemeContext\""
    echo "  $0 .claude/active/feature-add-dark-mode.md \"Add toggle to Header\""
    exit 1
fi

TASK_FILE=$1
TASK_NAME="$2"

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
# Format: feature-{slug}.md
BASENAME=$(basename "$TASK_FILE" .md)
FEATURE_SLUG=$(echo "$BASENAME" | sed 's/^feature-//')

# Check if file has uncommitted changes
if git diff --quiet "$TASK_FILE" 2>/dev/null && git diff --cached --quiet "$TASK_FILE" 2>/dev/null; then
    echo -e "${BLUE}ℹ️  No changes to commit${NC}"
    exit 0
fi

# Stage the task file
git add "$TASK_FILE"

# Create commit message
COMMIT_MSG="feat($FEATURE_SLUG): $TASK_NAME"

# Commit
if git commit -m "$COMMIT_MSG" > /dev/null 2>&1; then
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo -e "${GREEN}✅ Committed:${NC} $COMMIT_MSG"
    echo -e "${BLUE}   Commit:${NC} $COMMIT_HASH"
else
    echo -e "${YELLOW}⚠️  Commit failed (may be empty or already committed)${NC}"
    exit 0
fi
