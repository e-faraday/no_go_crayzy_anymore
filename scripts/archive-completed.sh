#!/bin/bash
# scripts/archive-completed.sh
# Archive completed tasks to completed/ directory

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

YEAR_MONTH=$(date +%Y-%m)
ARCHIVE_DIR=".claude/completed/$YEAR_MONTH"

echo -e "${BLUE}📦 Archiving completed tasks...${NC}"
echo ""

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# Count files to archive
COUNT=0
for file in .claude/active/*.md; do
    [ -f "$file" ] || continue
    if grep -q "status: completed" "$file" 2>/dev/null; then
        COUNT=$((COUNT + 1))
    fi
done

if [ $COUNT -eq 0 ]; then
    echo -e "${YELLOW}No completed tasks found.${NC}"
    echo ""
    echo "Mark tasks as completed by setting:"
    echo "  status: completed"
    echo ""
    echo "in the frontmatter of your MD files."
    exit 0
fi

echo "Found $COUNT completed task(s)"
echo ""

# Archive each completed task
for file in .claude/active/*.md; do
    [ -f "$file" ] || continue
    
    if grep -q "status: completed" "$file" 2>/dev/null; then
        BASENAME=$(basename "$file")
        echo -e "  ${GREEN}✓${NC} $BASENAME"
        
        # Use git mv if in a git repo and file is tracked, otherwise regular mv
        # Fallback to regular mv if git mv fails (e.g., dirty working tree)
        if git rev-parse --git-dir > /dev/null 2>&1 && git ls-files --error-unmatch "$file" > /dev/null 2>&1; then
            if ! git mv "$file" "$ARCHIVE_DIR/" 2>/dev/null; then
                # git mv failed, use regular mv and git add
                mv "$file" "$ARCHIVE_DIR/"
                git add "$ARCHIVE_DIR/$BASENAME" 2>/dev/null || true
            fi
        else
            mv "$file" "$ARCHIVE_DIR/"
        fi
    fi
done

echo ""
echo -e "${GREEN}✅ Archived $COUNT task(s) to $ARCHIVE_DIR${NC}"
echo ""
echo "To view archived tasks:"
echo "  ls $ARCHIVE_DIR/"
