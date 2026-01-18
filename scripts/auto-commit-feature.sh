#!/bin/bash
# scripts/auto-commit-feature.sh
# Automatically commit when a feature is completed

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
    echo "Automatically commits when a feature is completed."
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

# Check if git repo exists
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not a git repository, skipping commit${NC}"
    exit 0
fi

# Extract feature slug from filename
BASENAME=$(basename "$TASK_FILE" .md)
FEATURE_SLUG=$(echo "$BASENAME" | sed 's/^feature-//')

# Get feature name from file
FEATURE_NAME=$(grep "^## Feature:" "$TASK_FILE" | sed 's/^## Feature: *//' | head -1)
if [ -z "$FEATURE_NAME" ]; then
    FEATURE_NAME="$FEATURE_SLUG"
fi

# Count completed plans
PLAN_LINES=$(grep -n "^#### Plan" "$TASK_FILE" || true)
if [ -z "$PLAN_LINES" ]; then
    echo -e "${YELLOW}⚠️  No plans found${NC}"
    exit 1
fi

TOTAL_PLANS=$(echo "$PLAN_LINES" | wc -l | tr -d ' ')
COMPLETED_PLANS=$(echo "$PLAN_LINES" | grep -c "(✅ COMPLETED)" || echo "0")

# Get list of completed plans
COMPLETED_PLAN_NAMES=$(echo "$PLAN_LINES" | grep "(✅ COMPLETED)" | sed 's/^[0-9]*://' | sed 's/^#### Plan //' | sed 's/ (✅ COMPLETED)$//' | head -10)

# Check if file has uncommitted changes
if git diff --quiet "$TASK_FILE" 2>/dev/null && git diff --cached --quiet "$TASK_FILE" 2>/dev/null; then
    echo -e "${BLUE}ℹ️  No changes to commit${NC}"
    exit 0
fi

# Stage the task file
git add "$TASK_FILE"

# Create commit message
COMMIT_MSG="docs($FEATURE_SLUG): complete feature

Plans completed: $COMPLETED_PLANS/$TOTAL_PLANS"

# Add plan list if available
if [ -n "$COMPLETED_PLAN_NAMES" ]; then
    COMMIT_MSG="$COMMIT_MSG
$(echo "$COMPLETED_PLAN_NAMES" | sed 's/^/- Plan /')"
fi

# Commit
if git commit -m "$COMMIT_MSG" > /dev/null 2>&1; then
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo -e "${GREEN}✅ Committed:${NC} docs($FEATURE_SLUG): complete feature"
    echo -e "${BLUE}   Commit:${NC} $COMMIT_HASH"
else
    echo -e "${YELLOW}⚠️  Commit failed (may be empty or already committed)${NC}"
    exit 0
fi
