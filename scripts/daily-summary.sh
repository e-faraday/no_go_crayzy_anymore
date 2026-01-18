#!/bin/bash
# scripts/daily-summary.sh
# Show daily summary of tasks

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📊 Daily Summary - $(date +%Y-%m-%d)${NC}"
echo ""

# Count active tasks
ACTIVE_COUNT=$(ls -1 .claude/active/*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "${BLUE}📝 Active Tasks:${NC} $ACTIVE_COUNT"

# Count by type
FEATURE_COUNT=$(ls -1 .claude/active/feature-*.md 2>/dev/null | wc -l | tr -d ' ')
BUG_COUNT=$(ls -1 .claude/active/bug-*.md 2>/dev/null | wc -l | tr -d ' ')
REFACTOR_COUNT=$(ls -1 .claude/active/refactor-*.md 2>/dev/null | wc -l | tr -d ' ')
DECISION_COUNT=$(ls -1 .claude/active/decision-*.md 2>/dev/null | wc -l | tr -d ' ')

echo "  Features: $FEATURE_COUNT"
echo "  Bugs: $BUG_COUNT"
echo "  Refactors: $REFACTOR_COUNT"
echo "  Decisions: $DECISION_COUNT"
echo ""

# High priority tasks
echo -e "${RED}🔥 High Priority:${NC}"
HIGH_PRIORITY=$(grep -l "priority: high" .claude/active/*.md 2>/dev/null || true)
if [ -z "$HIGH_PRIORITY" ]; then
    echo "  None"
else
    echo "$HIGH_PRIORITY" | while read file; do
        BASENAME=$(basename "$file")
        STATUS=$(grep "^status:" "$file" | head -1 | cut -d: -f2 | tr -d ' ')
        echo "  - $BASENAME [$STATUS]"
    done
fi
echo ""

# In progress tasks
echo -e "${YELLOW}🏗️  In Progress:${NC}"
IN_PROGRESS=$(grep -l "status: in-progress\|status: in_progress" .claude/active/*.md 2>/dev/null || true)
if [ -z "$IN_PROGRESS" ]; then
    echo "  None"
else
    echo "$IN_PROGRESS" | while read file; do
        BASENAME=$(basename "$file")
        echo "  - $BASENAME"
    done
fi
echo ""

# Blocked tasks
echo -e "${RED}⚠️  Blocked:${NC}"
BLOCKED=$(grep -l "status: blocked" .claude/active/*.md 2>/dev/null || true)
if [ -z "$BLOCKED" ]; then
    echo "  None"
else
    echo "$BLOCKED" | while read file; do
        BASENAME=$(basename "$file")
        echo "  - $BASENAME"
    done
fi
echo ""

# Completed today
TODAY=$(date +%Y-%m-%d)
COMPLETED_TODAY=$(grep -l "updated: $TODAY" .claude/active/*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "${GREEN}✅ Updated Today:${NC} $COMPLETED_TODAY"
echo ""

# Recent decisions
echo -e "${BLUE}📋 Recent Decisions:${NC}"
RECENT_DECISIONS=$(ls -t .claude/decisions/*.md 2>/dev/null | head -3 || true)
if [ -z "$RECENT_DECISIONS" ]; then
    echo "  None"
else
    echo "$RECENT_DECISIONS" | while read file; do
        BASENAME=$(basename "$file")
        echo "  - $BASENAME"
    done
fi
echo ""

# Quick stats
TOTAL_COMPLETED=$(find .claude/completed -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo -e "${BLUE}📈 All-Time Stats:${NC}"
echo "  Total completed: $TOTAL_COMPLETED"
echo ""

echo -e "${GREEN}💡 Tip:${NC} Run './scripts/archive-completed.sh' to archive done tasks"
