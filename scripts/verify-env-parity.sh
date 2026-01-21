#!/bin/bash
# scripts/verify-env-parity.sh
# Verifies that local test configuration matches CI/CD configuration
# Prevents "works on my machine" issues

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Environment Parity Check${NC}"
echo ""

# Check if we're in a git repo
if [ ! -d .git ]; then
    echo -e "${YELLOW}⚠️  Not a git repository - skipping parity check${NC}"
    exit 0
fi

# Check if CI workflows exist
CI_WORKFLOWS_DIR=".github/workflows"
if [ ! -d "$CI_WORKFLOWS_DIR" ]; then
    echo -e "${YELLOW}⚠️  No CI workflows found - skipping parity check${NC}"
    exit 0
fi

# Check if test script exists
TEST_SCRIPT="scripts/test-active-mode.sh"
if [ ! -f "$TEST_SCRIPT" ]; then
    echo -e "${YELLOW}⚠️  Test script not found: $TEST_SCRIPT${NC}"
    exit 0
fi

# Extract test categories from CI workflows
echo -e "${BLUE}Analyzing CI workflows...${NC}"

CI_CATEGORIES=""
for workflow in "$CI_WORKFLOWS_DIR"/*.yml "$CI_WORKFLOWS_DIR"/*.yaml; do
    [ -f "$workflow" ] || continue
    # Extract category names from workflow files
    CATEGORIES=$(grep -E "category|--category" "$workflow" 2>/dev/null | grep -oE "(detection|enforcement|validation|precommit|freshchat|autosync|edgecases|integration|performance|errorhandling|all)" | sort -u || true)
    if [ -n "$CATEGORIES" ]; then
        CI_CATEGORIES="$CI_CATEGORIES $CATEGORIES"
    fi
done

# Remove duplicates and sort
CI_CATEGORIES=$(echo "$CI_CATEGORIES" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

# Check local test script for available categories
echo -e "${BLUE}Analyzing local test script...${NC}"

LOCAL_CATEGORIES=$(grep -E "test_category|--category" "$TEST_SCRIPT" 2>/dev/null | grep -oE "(detection|enforcement|validation|precommit|freshchat|autosync|edgecases|integration|performance|errorhandling|all)" | sort -u | tr '\n' ' ' | xargs || true)

# Compare
echo ""
echo -e "${BLUE}Comparison Results:${NC}"

if [ -z "$CI_CATEGORIES" ] && [ -z "$LOCAL_CATEGORIES" ]; then
    echo -e "${YELLOW}⚠️  Could not detect categories - assuming parity${NC}"
    exit 0
fi

# Check if "all" is in CI
if echo "$CI_CATEGORIES" | grep -q "all"; then
    # CI runs all tests - local should support "all" too
    if echo "$LOCAL_CATEGORIES" | grep -q "all"; then
        echo -e "${GREEN}✅ Parity OK: Both CI and local support 'all' tests${NC}"
        exit 0
    else
        echo -e "${RED}❌ Parity Mismatch: CI runs 'all' but local doesn't support it${NC}"
        exit 1
    fi
fi

# If CI has specific categories, check if local has them
MISMATCH=0
for category in $CI_CATEGORIES; do
    if ! echo "$LOCAL_CATEGORIES" | grep -q "$category"; then
        echo -e "${RED}❌ Parity Mismatch: CI runs '$category' but local doesn't support it${NC}"
        MISMATCH=1
    fi
done

if [ $MISMATCH -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Fix: Update local test script to support all CI categories${NC}"
    exit 1
fi

# Check for extra local categories (warning only)
for category in $LOCAL_CATEGORIES; do
    if ! echo "$CI_CATEGORIES" | grep -q "$category"; then
        echo -e "${YELLOW}⚠️  Warning: Local has '$category' but CI doesn't use it${NC}"
    fi
done

echo -e "${GREEN}✅ Environment Parity: OK${NC}"
echo ""
echo "CI Categories: $CI_CATEGORIES"
echo "Local Categories: $LOCAL_CATEGORIES"
exit 0
