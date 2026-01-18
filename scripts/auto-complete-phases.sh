#!/bin/bash
# scripts/auto-complete-phases.sh
# Automatically mark plans as completed when all checkboxes are checked

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
NO_COMMIT=false
if [ "$1" = "--no-commit" ]; then
    NO_COMMIT=true
    shift
fi

if [ "$#" -lt 1 ]; then
    echo -e "${RED}Usage: $0 [--no-commit] <task-file> [message]${NC}"
    echo ""
    echo "Options:"
    echo "  --no-commit    Skip automatic commit after marking plan complete"
    echo ""
    echo "Automatically marks plans as completed when all checkboxes are checked."
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"All setup tasks completed\""
    echo "  $0 --no-commit .claude/active/feature-add-dark-mode.md"
    exit 1
fi

TASK_FILE=$1
MESSAGE=${2:-"Plan automatically completed"}

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

COMPLETED_COUNT=0
COMPLETED_PLANS=""

# Find all plan headers
PLAN_LINES=$(grep -n "^#### Plan" "$TASK_FILE" || true)

if [ -z "$PLAN_LINES" ]; then
    echo -e "${YELLOW}⚠️  No plans found in file${NC}"
    exit 0
fi

# Process each plan
while IFS=: read -r LINE_NUM PLAN_HEADER; do
    # Extract plan number and name
    PLAN_INFO=$(echo "$PLAN_HEADER" | sed 's/^#### Plan //')
    PLAN_NUM=$(echo "$PLAN_INFO" | cut -d: -f1 | tr -d ' ')
    PLAN_NAME=$(echo "$PLAN_INFO" | cut -d: -f2- | sed 's/^ *//')
    
    # Check if already completed
    if echo "$PLAN_HEADER" | grep -q "(✅ COMPLETED)"; then
        continue
    fi
    
    # Find the range of this plan (from this line to next plan or end of plans section)
    NEXT_PLAN_LINE=$(grep -n "^#### Plan" "$TASK_FILE" | awk -F: -v current="$LINE_NUM" '$1 > current {print $1; exit}')
    if [ -z "$NEXT_PLAN_LINE" ]; then
        # Last plan, go to Acceptance Criteria or end
        NEXT_SECTION_LINE=$(grep -n "^### ✅ Acceptance Criteria\|^### 📝 Progress Log\|^### 🔖 Current Checkpoint" "$TASK_FILE" | head -1 | cut -d: -f1)
        if [ -z "$NEXT_SECTION_LINE" ]; then
            PLAN_END=$(wc -l < "$TASK_FILE")
        else
            PLAN_END=$((NEXT_SECTION_LINE - 1))
        fi
    else
        PLAN_END=$((NEXT_PLAN_LINE - 1))
    fi
    
    # Count checkboxes in this plan
    PLAN_TOTAL=$(sed -n "${LINE_NUM},${PLAN_END}p" "$TASK_FILE" | grep -c "^- \[" 2>/dev/null || echo "0")
    PLAN_CHECKED=$(sed -n "${LINE_NUM},${PLAN_END}p" "$TASK_FILE" | grep -c "^- \[x\]" 2>/dev/null || echo "0")
    
    # Ensure numeric values
    PLAN_TOTAL=$(echo "$PLAN_TOTAL" | tr -d '[:space:]')
    PLAN_CHECKED=$(echo "$PLAN_CHECKED" | tr -d '[:space:]')
    PLAN_TOTAL=${PLAN_TOTAL:-0}
    PLAN_CHECKED=${PLAN_CHECKED:-0}
    
    # If all checkboxes are checked and there are checkboxes
    if [ "$PLAN_TOTAL" -gt 0 ] && [ "$PLAN_CHECKED" -eq "$PLAN_TOTAL" ]; then
        # Mark plan as completed
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "${LINE_NUM}s/^#### Plan \(.*\)$/#### Plan \1 (✅ COMPLETED)/" "$TASK_FILE"
        else
            sed -i "${LINE_NUM}s/^#### Plan \(.*\)$/#### Plan \1 (✅ COMPLETED)/" "$TASK_FILE"
        fi
        
        COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
        COMPLETED_PLANS="$COMPLETED_PLANS$PLAN_NUM:$PLAN_NAME"$'\n'
        echo -e "${GREEN}✅ Plan $PLAN_NUM completed:${NC} $PLAN_NAME"
    fi
done <<< "$PLAN_LINES"

if [ "$COMPLETED_COUNT" -eq 0 ]; then
    echo -e "${BLUE}ℹ️  No plans ready for completion${NC}"
    echo "All plans need all checkboxes to be checked first."
else
    echo ""
    echo -e "${GREEN}✅ Marked $COMPLETED_COUNT plan(s) as completed${NC}"
    
    # Auto-commit for each completed plan
    if [ "$NO_COMMIT" != "true" ] && [ -f "./scripts/auto-commit-plan.sh" ]; then
        echo ""
        echo "$COMPLETED_PLANS" | while IFS=: read -r PLAN_NUM PLAN_NAME; do
            if [ -n "$PLAN_NUM" ]; then
                ./scripts/auto-commit-plan.sh "$TASK_FILE" "Plan $PLAN_NUM: $PLAN_NAME" 2>/dev/null || true
            fi
        done
    fi
    
    echo ""
    echo "Next steps:"
    echo "  - Update status: ./scripts/auto-update-status.sh $TASK_FILE"
    echo "  - Check if feature complete: ./scripts/auto-complete-task.sh $TASK_FILE"
    if [ "$NO_COMMIT" = "true" ]; then
        echo "  - Commit manually: git add $TASK_FILE && git commit -m \"docs(...): complete Plan(s)\""
    fi
fi
