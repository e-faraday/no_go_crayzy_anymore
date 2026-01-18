#!/bin/bash
# scripts/auto-complete-task.sh
# Automatically mark feature as completed when all plans are completed

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
    echo "Automatically marks feature as completed when all plans are completed."
    echo ""
    echo "Examples:"
    echo "  $0 .claude/active/feature-add-dark-mode.md"
    echo "  $0 .claude/active/feature-add-dark-mode.md \"All plans completed, ready for production\""
    exit 1
fi

TASK_FILE=$1
MESSAGE=${2:-"All plans completed"}

# Check if file exists
if [ ! -f "$TASK_FILE" ]; then
    echo -e "${RED}Error: Task file not found: $TASK_FILE${NC}"
    exit 1
fi

# Get current status
CURRENT_STATUS=$(grep "^status:" "$TASK_FILE" | head -1 | cut -d: -f2 | tr -d ' ')

if [ "$CURRENT_STATUS" = "completed" ]; then
    echo -e "${BLUE}ℹ️  Feature is already completed${NC}"
    exit 0
fi

# Find all plans
PLAN_LINES=$(grep -n "^#### Plan" "$TASK_FILE" || true)

if [ -z "$PLAN_LINES" ]; then
    echo -e "${YELLOW}⚠️  No plans found in file${NC}"
    echo "Cannot determine completion status without plans."
    exit 1
fi

TOTAL_PLANS=0
COMPLETED_PLANS=0

# Count plans
echo "$PLAN_LINES" | while IFS=: read -r LINE_NUM PLAN_HEADER; do
    TOTAL_PLANS=$((TOTAL_PLANS + 1))
    if echo "$PLAN_HEADER" | grep -q "(✅ COMPLETED)"; then
        COMPLETED_PLANS=$((COMPLETED_PLANS + 1))
    fi
done

# Re-count (because of subshell)
TOTAL_PLANS=$(echo "$PLAN_LINES" | wc -l | tr -d ' ')
COMPLETED_PLANS=$(echo "$PLAN_LINES" | grep -c "(✅ COMPLETED)" || echo "0")

# Check if all plans are completed
if [ "$TOTAL_PLANS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No plans found${NC}"
    exit 1
fi

if [ "$COMPLETED_PLANS" -lt "$TOTAL_PLANS" ]; then
    echo -e "${YELLOW}⚠️  Not all plans are completed${NC}"
    echo "Completed: $COMPLETED_PLANS/$TOTAL_PLANS"
    echo ""
    echo "Complete remaining plans first:"
    echo "$PLAN_LINES" | grep -v "(✅ COMPLETED)" | sed 's/^[0-9]*://' | sed 's/^#### /  - /'
    exit 0
fi

# All plans completed, mark feature as completed
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^status: .*/status: completed/" "$TASK_FILE"
else
    # Linux
    sed -i "s/^status: .*/status: completed/" "$TASK_FILE"
fi

# Update status at bottom
if grep -q "^\*\*Status:\*\*" "$TASK_FILE" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^\*\*Status:\*\* .*/\*\*Status:\*\* ✅ Completed/" "$TASK_FILE"
    else
        sed -i "s/^\*\*Status:\*\* .*/\*\*Status:\*\* ✅ Completed/" "$TASK_FILE"
    fi
fi

# Update Current Checkpoint
if grep -q "### 🔖 Current Checkpoint" "$TASK_FILE"; then
    DATE=$(date +%Y-%m-%d)
    TIME=$(date +%H:%M)
    CHECKPOINT_UPDATE="### 🔖 Current Checkpoint\\
✅ All plans completed\\
✅ Feature ready for archive\\
\\
**Completed:** $DATE $TIME"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^### 🔖 Current Checkpoint$/,/^---$/c\\
$CHECKPOINT_UPDATE\\
\\
---" "$TASK_FILE"
    else
        # Linux - more complex, use awk or similar
        awk -v update="$CHECKPOINT_UPDATE" '
            /^### 🔖 Current Checkpoint$/ { 
                print update; 
                in_checkpoint=1; 
                next 
            }
            in_checkpoint && /^---$/ { 
                print ""; 
                print $0; 
                in_checkpoint=0; 
                next 
            }
            in_checkpoint { next }
            { print }
        ' "$TASK_FILE" > "$TASK_FILE.tmp" && mv "$TASK_FILE.tmp" "$TASK_FILE"
    fi
fi

# Add progress log entry
if grep -q "### 📝 Progress Log" "$TASK_FILE"; then
    DATE=$(date +%Y-%m-%d)
    TIME=$(date +%H:%M)
    LOG_ENTRY="**$DATE $TIME** - ✅ Feature completed: $MESSAGE"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^### 📝 Progress Log$/a\\
\\
$LOG_ENTRY
" "$TASK_FILE"
    else
        sed -i "/^### 📝 Progress Log$/a\\\n$LOG_ENTRY" "$TASK_FILE"
    fi
fi

echo -e "${GREEN}✅ Feature marked as completed!${NC}"
echo ""
echo -e "${BLUE}All plans completed:${NC} $COMPLETED_PLANS/$TOTAL_PLANS"
echo -e "${BLUE}Message:${NC} $MESSAGE"
echo ""
echo "Next step:"
echo "  ./scripts/archive-completed.sh"
