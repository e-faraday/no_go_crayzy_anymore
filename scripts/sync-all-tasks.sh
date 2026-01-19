#!/bin/bash
# scripts/sync-all-tasks.sh
# Sync all active tasks automatically (for end-of-day routine)

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Syncing all active tasks...${NC}"
echo ""

# Count active tasks
ACTIVE_TASKS=$(ls -1 .claude/active/*.md 2>/dev/null | grep -v ".gitkeep" | grep -v ".swp" | wc -l | tr -d ' ')

if [ "$ACTIVE_TASKS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No active tasks found${NC}"
    exit 0
fi

echo -e "${BLUE}Found ${ACTIVE_TASKS} active task(s)${NC}"
echo ""

SYNCED_COUNT=0
COMPLETED_COUNT=0
SKIPPED_COUNT=0

# Sync each task
for file in .claude/active/*.md; do
    # Skip .gitkeep and other non-task files
    if [ ! -f "$file" ] || [[ "$file" == *".gitkeep"* ]] || [[ "$file" == *".swp"* ]]; then
        continue
    fi
    
    BASENAME=$(basename "$file")
    
    # Get status before sync
    OLD_STATUS=$(grep "^status:" "$file" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ' || echo "unknown")
    
    # Sync the task (suppress detailed output for cleaner display)
    if ./scripts/auto-sync.sh "$file" > /dev/null 2>&1; then
        SYNCED_COUNT=$((SYNCED_COUNT + 1))
        
        # Check if status changed to completed
        NEW_STATUS=$(grep "^status:" "$file" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ' || echo "unknown")
        if [ "$OLD_STATUS" != "completed" ] && [ "$NEW_STATUS" = "completed" ]; then
            COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
            echo -e "  ${GREEN}✓${NC} $BASENAME ${GREEN}(→ completed)${NC}"
        else
            echo -e "  ${GREEN}✓${NC} $BASENAME"
        fi
    else
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        echo -e "  ${YELLOW}⚠${NC}  $BASENAME (skipped)"
    fi
done

echo ""
echo -e "${GREEN}✅ Sync complete${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Synced: $SYNCED_COUNT task(s)"
if [ "$COMPLETED_COUNT" -gt 0 ]; then
    echo -e "  ${GREEN}Completed: $COMPLETED_COUNT task(s)${NC}"
fi
if [ "$SKIPPED_COUNT" -gt 0 ]; then
    echo -e "  ${YELLOW}Skipped: $SKIPPED_COUNT task(s)${NC}"
fi

if [ "$COMPLETED_COUNT" -gt 0 ]; then
    echo ""
    echo "Next step:"
    echo "  ./scripts/archive-completed.sh"
fi
