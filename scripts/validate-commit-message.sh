#!/bin/bash
# scripts/validate-commit-message.sh
# Validates commit messages follow Conventional Commits format
# Format: type(scope): description

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get commit message
COMMIT_MSG_FILE="$1"
if [ -z "$COMMIT_MSG_FILE" ]; then
    COMMIT_MSG_FILE=".git/COMMIT_EDITMSG"
fi

if [ ! -f "$COMMIT_MSG_FILE" ]; then
    echo -e "${YELLOW}⚠️  Commit message file not found - skipping validation${NC}"
    exit 0
fi

COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Skip merge commits and revert commits
if echo "$COMMIT_MSG" | grep -qE "^(Merge|Revert)"; then
    exit 0
fi

# Conventional Commits pattern
# type(scope): description
# Valid types: feat, fix, docs, style, refactor, test, chore, perf, ci, build
PATTERN="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build)(\(.+\))?: .+"

if echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo -e "${GREEN}✅ Commit message format: OK${NC}"
    exit 0
fi

# Error message
echo -e "${RED}❌ Invalid commit message format${NC}"
echo ""
echo "Commit message must follow Conventional Commits format:"
echo "  type(scope): description"
echo ""
echo "Valid types:"
echo "  feat     - New feature"
echo "  fix      - Bug fix"
echo "  docs     - Documentation"
echo "  style    - Formatting"
echo "  refactor - Code refactoring"
echo "  test     - Test changes"
echo "  chore    - Build/CI changes"
echo "  perf     - Performance improvement"
echo "  ci       - CI/CD changes"
echo "  build    - Build system changes"
echo ""
echo "Examples:"
echo "  feat(active-mode): add environment parity check"
echo "  fix(validation): correct state update logic"
echo "  docs(readme): update workflow diagram"
echo "  test(ci): add affected tests detection"
echo ""
echo "Your commit message:"
echo "  $COMMIT_MSG"
echo ""
exit 1
