#!/bin/bash
# scripts/auto-update-checkpoint.sh
# Automatically update Current Checkpoint based on most active plan

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
    echo "Automatically updates Current Checkpoint based on plan with most checked boxes."
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

# Find all plan headers
PLAN_LINES=$(grep -n "^#### Plan" "$TASK_FILE" || true)

if [ -z "$PLAN_LINES" ]; then
    echo -e "${YELLOW}⚠️  No plans found in file${NC}"
    exit 0
fi

MOST_ACTIVE_PLAN=""
MOST_ACTIVE_COUNT=0
MOST_ACTIVE_LINE=0
NEXT_PLAN=""

# Process each plan to find the most active one
PREV_PLAN_INFO=""
while IFS=: read -r LINE_NUM PLAN_HEADER; do
    # Extract plan info
    PLAN_INFO=$(echo "$PLAN_HEADER" | sed 's/^#### Plan //' | sed 's/ (✅ COMPLETED)//')
    PLAN_NUM=$(echo "$PLAN_INFO" | cut -d: -f1 | tr -d ' ')
    PLAN_NAME=$(echo "$PLAN_INFO" | cut -d: -f2- | sed 's/^ *//')
    
    # Find plan range
    NEXT_PLAN_LINE=$(grep -n "^#### Plan" "$TASK_FILE" | awk -F: -v current="$LINE_NUM" '$1 > current {print $1; exit}')
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
    
    # Count checkboxes in this plan
    PLAN_TOTAL=$(sed -n "${LINE_NUM},${PLAN_END}p" "$TASK_FILE" | grep -c "^- \[" 2>/dev/null || echo "0")
    PLAN_CHECKED=$(sed -n "${LINE_NUM},${PLAN_END}p" "$TASK_FILE" | grep -c "^- \[x\]" 2>/dev/null || echo "0")
    
    # Ensure numeric values
    PLAN_TOTAL=$(echo "$PLAN_TOTAL" | tr -d '[:space:]')
    PLAN_CHECKED=$(echo "$PLAN_CHECKED" | tr -d '[:space:]')
    PLAN_TOTAL=${PLAN_TOTAL:-0}
    PLAN_CHECKED=${PLAN_CHECKED:-0}
    
    # Calculate progress percentage
    if [ "$PLAN_TOTAL" -gt 0 ]; then
        PROGRESS=$((PLAN_CHECKED * 100 / PLAN_TOTAL))
    else
        PROGRESS=0
    fi
    
    # Check if this is the most active plan (highest progress but not 100%)
    if [ "$PROGRESS" -gt "$MOST_ACTIVE_COUNT" ] && [ "$PROGRESS" -lt 100 ]; then
        MOST_ACTIVE_COUNT=$PROGRESS
        MOST_ACTIVE_PLAN="Plan $PLAN_NUM: $PLAN_NAME"
        MOST_ACTIVE_LINE=$LINE_NUM
        
        # Find next plan
        if [ -n "$NEXT_PLAN_LINE" ]; then
            NEXT_PLAN_HEADER=$(sed -n "${NEXT_PLAN_LINE}p" "$TASK_FILE")
            NEXT_PLAN_INFO=$(echo "$NEXT_PLAN_HEADER" | sed 's/^#### Plan //' | sed 's/ (✅ COMPLETED)//')
            NEXT_PLAN_NUM=$(echo "$NEXT_PLAN_INFO" | cut -d: -f1 | tr -d ' ')
            NEXT_PLAN_NAME=$(echo "$NEXT_PLAN_INFO" | cut -d: -f2- | sed 's/^ *//')
            NEXT_PLAN="Plan $NEXT_PLAN_NUM: $NEXT_PLAN_NAME"
        else
            NEXT_PLAN="Final review and deployment"
        fi
    fi
    
    PREV_PLAN_INFO="$PLAN_INFO"
done <<< "$PLAN_LINES"

# If no active plan found, check for completed plans
if [ -z "$MOST_ACTIVE_PLAN" ]; then
    # Check if all plans are completed
    ALL_COMPLETED=$(echo "$PLAN_LINES" | grep -c "(✅ COMPLETED)" || echo "0")
    TOTAL=$(echo "$PLAN_LINES" | wc -l | tr -d ' ')
    
    if [ "$ALL_COMPLETED" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
        MOST_ACTIVE_PLAN="✅ All plans completed"
        NEXT_PLAN="Ready for archive"
    else
        # Find first incomplete plan
        FIRST_INCOMPLETE=$(echo "$PLAN_LINES" | grep -v "(✅ COMPLETED)" | head -1)
        if [ -n "$FIRST_INCOMPLETE" ]; then
            LINE_NUM=$(echo "$FIRST_INCOMPLETE" | cut -d: -f1)
            PLAN_HEADER=$(echo "$FIRST_INCOMPLETE" | cut -d: -f2-)
            PLAN_INFO=$(echo "$PLAN_HEADER" | sed 's/^#### Plan //')
            PLAN_NUM=$(echo "$PLAN_INFO" | cut -d: -f1 | tr -d ' ')
            PLAN_NAME=$(echo "$PLAN_INFO" | cut -d: -f2- | sed 's/^ *//')
            MOST_ACTIVE_PLAN="Plan $PLAN_NUM: $PLAN_NAME"
            
            # Find next plan
            NEXT_PLAN_LINE=$(grep -n "^#### Plan" "$TASK_FILE" | awk -F: -v current="$LINE_NUM" '$1 > current {print $1; exit}')
            if [ -n "$NEXT_PLAN_LINE" ]; then
                NEXT_PLAN_HEADER=$(sed -n "${NEXT_PLAN_LINE}p" "$TASK_FILE")
                NEXT_PLAN_INFO=$(echo "$NEXT_PLAN_HEADER" | sed 's/^#### Plan //' | sed 's/ (✅ COMPLETED)//')
                NEXT_PLAN_NUM=$(echo "$NEXT_PLAN_INFO" | cut -d: -f1 | tr -d ' ')
                NEXT_PLAN_NAME=$(echo "$NEXT_PLAN_INFO" | cut -d: -f2- | sed 's/^ *//')
                NEXT_PLAN="Plan $NEXT_PLAN_NUM: $NEXT_PLAN_NAME"
            else
                NEXT_PLAN="Final review"
            fi
        fi
    fi
fi

if [ -z "$MOST_ACTIVE_PLAN" ]; then
    echo -e "${YELLOW}⚠️  Could not determine active plan${NC}"
    exit 1
fi

# Update Current Checkpoint section
if grep -q "### 🔖 Current Checkpoint" "$TASK_FILE"; then
    CHECKPOINT_UPDATE="### 🔖 Current Checkpoint\\
Working on: $MOST_ACTIVE_PLAN\\
Next: $NEXT_PLAN"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - find the section and replace until next section or end
        CHECKPOINT_LINE=$(grep -n "^### 🔖 Current Checkpoint" "$TASK_FILE" | cut -d: -f1)
        NEXT_SECTION_LINE=$(grep -n "^###\|^---" "$TASK_FILE" | awk -F: -v current="$CHECKPOINT_LINE" '$1 > current {print $1; exit}')
        
        if [ -n "$NEXT_SECTION_LINE" ]; then
            # Delete old checkpoint content and insert new
            sed -i '' "${CHECKPOINT_LINE},$((NEXT_SECTION_LINE-1))d" "$TASK_FILE"
            sed -i '' "${CHECKPOINT_LINE}i\\
$CHECKPOINT_UPDATE
" "$TASK_FILE"
        else
            # No next section, replace to end
            sed -i '' "${CHECKPOINT_LINE},\$c\\
$CHECKPOINT_UPDATE
" "$TASK_FILE"
        fi
    else
        # Linux - use awk
        awk -v update="$CHECKPOINT_UPDATE" '
            /^### 🔖 Current Checkpoint$/ { 
                print update; 
                in_checkpoint=1; 
                next 
            }
            in_checkpoint && (/^###/ || /^---$/) { 
                print $0; 
                in_checkpoint=0; 
                next 
            }
            in_checkpoint { next }
            { print }
        ' "$TASK_FILE" > "$TASK_FILE.tmp" && mv "$TASK_FILE.tmp" "$TASK_FILE"
    fi
    
    echo -e "${GREEN}✅ Current Checkpoint updated${NC}"
    echo ""
    echo -e "${BLUE}Working on:${NC} $MOST_ACTIVE_PLAN"
    echo -e "${BLUE}Next:${NC} $NEXT_PLAN"
else
    echo -e "${YELLOW}⚠️  Current Checkpoint section not found${NC}"
    echo "Adding it before final status..."
    
    # Add before final status or at end
    if grep -q "^---$" "$TASK_FILE"; then
        CHECKPOINT_SECTION="\\
\\
### 🔖 Current Checkpoint\\
Working on: $MOST_ACTIVE_PLAN\\
Next: $NEXT_PLAN\\
\\
---"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/^---$/i\\
$CHECKPOINT_SECTION
" "$TASK_FILE"
        else
            sed -i "/^---$/i\\$CHECKPOINT_SECTION" "$TASK_FILE"
        fi
    else
        CHECKPOINT_SECTION="\\
\\
### 🔖 Current Checkpoint\\
Working on: $MOST_ACTIVE_PLAN\\
Next: $NEXT_PLAN"
        echo -e "\n$CHECKPOINT_SECTION" >> "$TASK_FILE"
    fi
    
    echo -e "${GREEN}✅ Current Checkpoint section added${NC}"
fi
