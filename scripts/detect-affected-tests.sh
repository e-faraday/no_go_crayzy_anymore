#!/bin/bash
# scripts/detect-affected-tests.sh
# Detects which test categories are affected by changed files
# Optimizes test execution by running only relevant tests

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if we're in a git repo
if [ ! -d .git ]; then
    echo -e "${YELLOW}⚠️  Not a git repository - cannot detect changes${NC}"
    echo "all"
    exit 0
fi

# Get changed files
if [ -n "$1" ]; then
    # Compare with specific commit/branch
    CHANGED_FILES=$(git diff --name-only "$1" HEAD 2>/dev/null || echo "")
else
    # Check for staged changes first (pre-commit context)
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
    if [ -n "$STAGED_FILES" ]; then
        # Use staged changes if available
        CHANGED_FILES="$STAGED_FILES"
    else
        # Compare with previous commit (post-commit context)
        CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
    fi
fi

# If no changes, return empty
if [ -z "$CHANGED_FILES" ]; then
    echo ""
    exit 0
fi

echo -e "${BLUE}🔍 Detecting affected tests...${NC}"
echo "Changed files:"
echo "$CHANGED_FILES" | head -10
echo ""

# Map file patterns to test categories
AFFECTED_CATEGORIES=""

# Check for script changes
if echo "$CHANGED_FILES" | grep -qE "(scripts/validate-state|scripts/auto-sync|\.git/hooks/pre-commit)"; then
    AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES validation autosync precommit"
fi

# Check for test script changes
if echo "$CHANGED_FILES" | grep -qE "scripts/test-active-mode"; then
    AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES all"
fi

# Check for CI workflow changes
if echo "$CHANGED_FILES" | grep -qE "\.github/workflows"; then
    AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES all"
fi

# Check for state tracking rules
if echo "$CHANGED_FILES" | grep -qE "\.cursor/rules/(state-tracking|fresh-chat-protocol)"; then
    AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES detection enforcement freshchat"
fi

# Check for feature files
if echo "$CHANGED_FILES" | grep -qE "\.claude/active"; then
    AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES detection enforcement"
fi

# Check for test fixtures
if echo "$CHANGED_FILES" | grep -qE "tests/fixtures"; then
    AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES edgecases"
fi

# Check for documentation that might affect tests
if echo "$CHANGED_FILES" | grep -qE "(README|WORKFLOW|docs/.*\.md)"; then
    # Documentation changes usually don't affect tests, but check anyway
    if echo "$CHANGED_FILES" | grep -qE "docs/DEVELOPER_WORKFLOW"; then
        # Workflow diagram changes might indicate process changes
        AFFECTED_CATEGORIES="$AFFECTED_CATEGORIES integration"
    fi
fi

# Remove duplicates and sort
AFFECTED_CATEGORIES=$(echo "$AFFECTED_CATEGORIES" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

# If we detected "all", return that
if echo "$AFFECTED_CATEGORIES" | grep -q "all"; then
    echo -e "${YELLOW}⚠️  Major changes detected - running all tests${NC}"
    echo "all"
    exit 0
fi

# If no specific categories detected, default to critical ones
if [ -z "$AFFECTED_CATEGORIES" ]; then
    echo -e "${YELLOW}⚠️  No specific categories detected - defaulting to critical tests${NC}"
    echo "detection enforcement validation"
    exit 0
fi

echo -e "${GREEN}✅ Affected categories: $AFFECTED_CATEGORIES${NC}"
echo "$AFFECTED_CATEGORIES"
exit 0
