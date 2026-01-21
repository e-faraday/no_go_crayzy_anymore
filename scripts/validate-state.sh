#!/bin/bash
# scripts/validate-state.sh
# Validates that state is updated after code changes
# Bootstrap-aware: Skips validation in bootstrap mode

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for --strict flag
STRICT_MODE=false
if [ "$1" = "--strict" ]; then
    STRICT_MODE=true
    shift
fi

# Mode detection
ACTIVE_COUNT=$(ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | wc -l)

# Bootstrap Mode: No active features
if [ $ACTIVE_COUNT -eq 0 ]; then
    if [ "$STRICT_MODE" = "true" ]; then
        echo -e "${GREEN}✅ Bootstrap mode - no active features (OK)${NC}"
    fi
    exit 0  # Not an error
fi

# Active Mode: Features exist, check state

# Check if git repo exists
if [ ! -d .git ]; then
    echo -e "${YELLOW}⚠️  Warning: Not a git repository${NC}"
    echo "State validation requires git to track changes."
    exit 0  # Not blocking if no git
fi

# Check if there are any commits
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")

# Detect if we're in a pre-commit hook (check staged changes) or post-commit (check last commit)
STAGED_CHANGES=$(git diff --cached --name-only 2>/dev/null | wc -l || echo "0")

if [ "$STAGED_CHANGES" -gt 0 ]; then
    # Pre-commit hook: Check staged changes against HEAD
    CODE_CHANGED=$(git diff --cached --name-only 2>/dev/null | grep -v "^.claude/" | grep -v "^.cursor/" | grep -v "^.git/" | wc -l || echo "0")
    
    if [ "$CODE_CHANGED" -eq 0 ]; then
        echo -e "${GREEN}✅ No code changes in staged files - state validation skipped${NC}"
        exit 0
    fi
    
    # Code changed - verify state was updated in staged files
    STATE_UPDATED=$(git diff --cached --name-only 2>/dev/null | grep "^.claude/active/" | wc -l || echo "0")
    CHANGED_FILES_CMD="git diff --cached --name-only 2>/dev/null"
    FEATURE_FILE_CMD="git diff --cached --name-only 2>/dev/null | grep '^.claude/active/' | head -1"
else
    # Post-commit validation: Check last commit
    if [ "$COMMIT_COUNT" -eq 0 ]; then
        echo -e "${BLUE}ℹ️  No commits yet - state validation skipped${NC}"
        exit 0  # First commit, no history to compare
    fi
    
    CODE_CHANGED=$(git diff HEAD~1 HEAD --name-only 2>/dev/null | grep -v "^.claude/" | grep -v "^.cursor/" | grep -v "^.git/" | wc -l || echo "0")
    
    if [ "$CODE_CHANGED" -eq 0 ]; then
        echo -e "${GREEN}✅ No code changes in last commit - state validation skipped${NC}"
        exit 0
    fi
    
    # Code changed - verify state was updated
    STATE_UPDATED=$(git diff HEAD~1 HEAD --name-only 2>/dev/null | grep "^.claude/active/" | wc -l || echo "0")
    CHANGED_FILES_CMD="git diff HEAD~1 HEAD --name-only 2>/dev/null"
    FEATURE_FILE_CMD="git diff HEAD~1 HEAD --name-only 2>/dev/null | grep '^.claude/active/' | head -1"
fi

if [ "$STATE_UPDATED" -eq 0 ]; then
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo ""
    echo -e "${RED}Code changed but state not updated${NC}"
    echo ""
    echo "Files changed:"
    eval "$CHANGED_FILES_CMD" | grep -v "^.claude/" | grep -v "^.cursor/" | head -10
    echo ""
    echo "Active features:"
    ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | head -3
    echo ""
    echo -e "${YELLOW}Fix:${NC}"
    echo "  1. ./scripts/auto-sync.sh .claude/active/your-feature.md"
    echo "  2. git add .claude/active/your-feature.md"
    if [ "$STAGED_CHANGES" -gt 0 ]; then
        echo "  3. git commit (state file is now staged)"
    else
        echo "  3. git commit --amend (or make new commit)"
    fi
    echo ""
    exit 2  # Hard error - blocking
fi

# State was updated - check if Progress Log has recent entry
FEATURE_FILE=$(eval "$FEATURE_FILE_CMD")

if [ -n "$FEATURE_FILE" ] && [ -f "$FEATURE_FILE" ]; then
    TODAY=$(date +%Y-%m-%d)
    
    # Check if Progress Log section exists and has today's date
    if grep -q "### 📝 Progress Log" "$FEATURE_FILE"; then
        if ! grep -A 20 "### 📝 Progress Log" "$FEATURE_FILE" | grep -q "$TODAY"; then
            echo -e "${YELLOW}⚠️  WARNING: Progress Log has no entry for today ($TODAY)${NC}"
            echo ""
            echo "Consider adding progress entry:"
            echo "  ./scripts/update-progress.sh $FEATURE_FILE 'Your progress message'"
            echo ""
            
            if [ "$STRICT_MODE" = "true" ]; then
                exit 1  # Warning in strict mode
            fi
        fi
    fi
    
    # Check if checkpoint section exists
    if ! grep -q "### 🔖 Current Checkpoint" "$FEATURE_FILE"; then
        echo -e "${YELLOW}⚠️  WARNING: Feature file missing Current Checkpoint section${NC}"
        echo ""
        echo "Consider updating checkpoint:"
        echo "  ./scripts/auto-update-checkpoint.sh $FEATURE_FILE"
        echo ""
        
        if [ "$STRICT_MODE" = "true" ]; then
            exit 1  # Warning in strict mode
        fi
    fi
fi

# All checks passed
echo -e "${GREEN}✅ State validation passed${NC}"
exit 0
