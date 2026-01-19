#!/bin/bash
# scripts/new-task.sh
# Create a new task from template

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <type> <title>${NC}"
    echo ""
    echo "Types: feature, bug, refactor, decision"
    echo ""
    echo "Examples:"
    echo "  $0 feature \"Add dark mode\""
    echo "  $0 bug \"Login fails on Safari\""
    echo "  $0 refactor \"Simplify auth logic\""
    echo "  $0 decision \"Choose state management\""
    exit 1
fi

TYPE=$1
TITLE=$2

# Validate type
if [[ ! "$TYPE" =~ ^(feature|bug|refactor|decision)$ ]]; then
    echo -e "${RED}Error: Invalid type '$TYPE'${NC}"
    echo "Valid types: feature, bug, refactor, decision"
    exit 1
fi

# Create slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
FILE=".claude/active/${TYPE}-${SLUG}.md"

# Check if file already exists
if [ -f "$FILE" ]; then
    echo -e "${YELLOW}Warning: File already exists: $FILE${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 1
    fi
fi

# Create .claude/active directory if it doesn't exist
mkdir -p .claude/active

# Copy template
TEMPLATE=".claude/templates/${TYPE}.md"
if [ ! -f "$TEMPLATE" ]; then
    echo -e "${RED}Error: Template not found: $TEMPLATE${NC}"
    exit 1
fi

cp "$TEMPLATE" "$FILE"

# Replace placeholders
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/YYYY-MM-DD/$DATE/g" "$FILE"
    sed -i '' "s/HH:MM/$TIME/g" "$FILE"
    sed -i '' "s/\[Name\]/$TITLE/g" "$FILE"
    sed -i '' "s/\[Description\]/$TITLE/g" "$FILE"
    sed -i '' "s/\[What\]/$TITLE/g" "$FILE"
    sed -i '' "s/\[Topic\]/$TITLE/g" "$FILE"
else
    # Linux
    sed -i "s/YYYY-MM-DD/$DATE/g" "$FILE"
    sed -i "s/HH:MM/$TIME/g" "$FILE"
    sed -i "s/\[Name\]/$TITLE/g" "$FILE"
    sed -i "s/\[Description\]/$TITLE/g" "$FILE"
    sed -i "s/\[What\]/$TITLE/g" "$FILE"
    sed -i "s/\[Topic\]/$TITLE/g" "$FILE"
fi

echo -e "${GREEN}✅ Created: $FILE${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit the file to add details"
echo "  2. Start working: claude"
echo "  3. Reference it: @$FILE implement this"
echo ""

# Open in editor if available
if command -v code &> /dev/null; then
    code "$FILE"
elif command -v vim &> /dev/null; then
    vim "$FILE"
else
    echo "Open $FILE in your editor to get started"
fi

# -------------------------------------------------------------------

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
        
        # Use git mv if in a git repo, otherwise regular mv
        if git rev-parse --git-dir > /dev/null 2>&1; then
            git mv "$file" "$ARCHIVE_DIR/"
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

# -------------------------------------------------------------------

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

# -------------------------------------------------------------------

#!/bin/bash
# scripts/setup.sh
# Setup MDD structure for new project

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up MD-Driven Development...${NC}"
echo ""

# Create directory structure
echo "Creating directories..."
mkdir -p .claude/active
mkdir -p .claude/completed
mkdir -p .claude/templates
mkdir -p .claude/decisions
mkdir -p scripts

# Create .gitkeep files
touch .claude/active/.gitkeep
touch .claude/completed/.gitkeep
touch .claude/decisions/.gitkeep

echo -e "${GREEN}✅ Directory structure created${NC}"
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}✅ Scripts are executable${NC}"
echo ""

# Check for git
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Git repository detected"
    
    # Add to git
    git add .claude/ scripts/
    
    echo -e "${GREEN}✅ Files staged for commit${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. git commit -m 'Add MD-Driven Development setup'"
    echo "  2. ./scripts/new-task.sh feature 'Your First Feature'"
else
    echo -e "${BLUE}ℹ️  Not a git repository${NC}"
    echo ""
    echo "Consider initializing git:"
    echo "  git init"
fi

echo ""
echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo "Quick start:"
echo "  ./scripts/new-task.sh feature 'Feature Name'"
echo "  ./scripts/daily-summary.sh"
echo ""
echo "Documentation: .claude/README.md"