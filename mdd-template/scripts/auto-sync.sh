#!/bin/bash
# scripts/auto-sync.sh
# Run all automatic updates on a task file

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
    echo "Runs all automatic updates on a task:"
    echo "  1. Auto-complete phases (if all checkboxes checked)"
    echo "  2. Auto-update status (based on checkbox completion)"
    echo "  3. Auto-update checkpoint (based on most active phase)"
    echo "  4. Auto-complete task (if all phases completed)"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md"
    echo ""
    echo "Or sync all active tasks:"
    echo "  for file in .claude/active/*.md; do ./scripts/auto-sync.sh \"\$file\"; done"
    exit 1
fi

TASK_FILE=$1

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

BASENAME=$(basename "$TASK_FILE")

echo -e "${BLUE}🔄 Syncing:${NC} $BASENAME"
echo ""

# Step 1: Auto-complete phases
echo -e "${BLUE}1. Checking phases...${NC}"
if ./scripts/auto-complete-phases.sh "$TASK_FILE" > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} Phases checked"
else
    echo -e "   ${YELLOW}⚠${NC}  No phases to complete"
fi

# Step 2: Auto-update status
echo -e "${BLUE}2. Updating status...${NC}"
./scripts/auto-update-status.sh "$TASK_FILE" > /dev/null 2>&1 || true
echo -e "   ${GREEN}✓${NC} Status updated"

# Step 3: Auto-update checkpoint
echo -e "${BLUE}3. Updating checkpoint...${NC}"
if ./scripts/auto-update-checkpoint.sh "$TASK_FILE" > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} Checkpoint updated"
else
    echo -e "   ${YELLOW}⚠${NC}  Checkpoint update skipped"
fi

# Step 4: Auto-complete task (if all phases done)
echo -e "${BLUE}4. Checking task completion...${NC}"
if ./scripts/auto-complete-task.sh "$TASK_FILE" > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} Task marked as completed!"
else
    echo -e "   ${BLUE}ℹ${NC}  Task not ready for completion"
fi

echo ""
echo -e "${GREEN}✅ Sync complete for:${NC} $BASENAME"
