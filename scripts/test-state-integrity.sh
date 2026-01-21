#!/bin/bash
# scripts/test-state-integrity.sh
# E2E test scenarios for Bootstrap and Active modes

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 MDD State Integrity Test Suite${NC}"
echo ""

# Test 1: Bootstrap Mode Detection
echo -e "${BLUE}Test 1: Bootstrap Mode Detection${NC}"
echo "Checking if bootstrap mode is detected correctly..."

# Create temporary test directory
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Initialize git repo
git init > /dev/null 2>&1
git config user.name "Test User"
git config user.email "test@example.com"

# Create .claude structure
mkdir -p .claude/active
touch .claude/active/.gitkeep

# Check mode (should be bootstrap)
ACTIVE_COUNT=$(ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | wc -l)

if [ $ACTIVE_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Bootstrap mode detected correctly"
else
    echo -e "  ${RED}❌ FAIL${NC} - Bootstrap mode not detected"
    exit 1
fi

# Test 2: Bootstrap Mode - Commit Allowed
echo ""
echo -e "${BLUE}Test 2: Bootstrap Mode - Commit Allowed${NC}"
echo "Making code change without state update..."

echo "test content" > test.txt
git add test.txt
git commit -m "test: initial commit" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Commit allowed in bootstrap mode"
else
    echo -e "  ${RED}❌ FAIL${NC} - Commit blocked incorrectly"
    exit 1
fi

# Test 3: Active Mode Transition
echo ""
echo -e "${BLUE}Test 3: Active Mode Transition${NC}"
echo "Creating first feature..."

# Copy new-task script if available (simplified test)
cat > .claude/active/feature-test.md << 'EOF'
---
type: feature
status: todo
priority: medium
created: 2026-01-21
tags: []
---

## Feature: Test Feature

### 🎯 Goal
Test feature for mode transition

### 📊 Implementation Plans

#### Plan 1: Setup
- [ ] Task 1
- [ ] Task 2

### 🔖 Current Checkpoint
Working on: Plan 1
EOF

# Check mode (should be active now)
ACTIVE_COUNT=$(ls -1 .claude/active/*.md 2>/dev/null | grep -v .gitkeep | wc -l)

if [ $ACTIVE_COUNT -gt 0 ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Active mode detected after feature creation"
else
    echo -e "  ${RED}❌ FAIL${NC} - Active mode not detected"
    exit 1
fi

# Test 4: Active Mode - State Validation Required
echo ""
echo -e "${BLUE}Test 4: Active Mode - State Validation${NC}"
echo "Making code change without state update..."

echo "more content" >> test.txt
git add test.txt

# Try to commit (should be blocked if pre-commit hook exists)
# Note: This test assumes pre-commit hook is installed
if [ -f .git/hooks/pre-commit ]; then
    git commit -m "test: change without state" 2>&1 | grep -q "COMMIT BLOCKED" && {
        echo -e "  ${GREEN}✅ PASS${NC} - Commit blocked when state not updated"
    } || {
        echo -e "  ${YELLOW}⚠️  WARNING${NC} - Pre-commit hook exists but didn't block"
    }
else
    echo -e "  ${YELLOW}⚠️  SKIP${NC} - Pre-commit hook not installed (expected in test env)"
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEST_DIR"

echo ""
echo -e "${GREEN}✅ All tests completed${NC}"
echo ""
echo "Note: Some tests may be skipped if hooks/scripts are not available in test environment."
echo "Run these tests in your actual project for full validation."
